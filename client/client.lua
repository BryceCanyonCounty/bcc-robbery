local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
local MiniGame = exports['bcc-minigames'].initiate()

local RobberyEnabled, Inmission = false, false
local DoReset, Countdown = false, false
local Timer = 0

-- Command to Enable/Disable Robberies
RegisterCommand(Config.RobberyCommand, function()
    if not RobberyEnabled then
        local result = Core.Callback.TriggerAwait('bcc-robbery:RobberyCheck')
        if result then
            RobberyEnabled = true
            Core.NotifyRightTip(_U('RobberyEnable'), 4000)
            Citizen.CreateThread(function()
                while RobberyEnabled do
                    Citizen.Wait(0)
                    for _, coords in ipairs(Markers) do
                        Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, coords.x, coords.y, coords.z - 0.9, 0, 0, 0, --you can change the marker @ (https://github.com/femga/rdr3_discoveries/blob/master/graphics/markers/marker_types.lua)
                            0, 0, 0, 1.0, 1.0, 1.0, 250, 250, 100, 250, 0, 0, 2, 0, 0, 0, 0)
                    end
                    if not RobberyEnabled then
                        break
                    end
                end
            end)
        else
            RobberyEnabled = false
        end
    else
        RobberyEnabled = false
        Core.NotifyRightTip(_U('RobberyDisable'), 4000)
    end
end, false)

CreateThread(function()
    local playerCoords
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()

        if not RobberyEnabled or Inmission or IsEntityDead(playerPed) then goto END end

        playerCoords = GetEntityCoords(playerPed)

        for _, locationCfg in pairs(Locations) do
            local distance = #(playerCoords - locationCfg.StartingCoords)
            if distance <= locationCfg.Distance then
                sleep = 0
                if IsPedShooting(playerPed) then
                    local result = Core.Callback.TriggerAwait('bcc-robbery:CheckCooldown', locationCfg)
                    if result then
                        Inmission = true
                        TriggerEvent('bcc-robbery:RobberyHandler', locationCfg)
                    else
                        Core.NotifyRightTip(_U('OnCooldown'), 4000)
                        Wait(5000)
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

local function ResetRobbery()
    Inmission = false
    Countdown = false
    Core.NotifyRightTip(_U('RobberyFail'), 4000)
    Wait(5000)
    DoReset = false
end

AddEventHandler('bcc-robbery:RobberyHandler', function(locationCfg)
    Core.NotifyRightTip(_U('RobberyStart'), 4000)

    if locationCfg.EnemyNpcs then
        TriggerEvent('bcc-robbery:EnemyPeds', locationCfg)
    end

    Countdown = true
    TriggerEvent('bcc-robbery:Countdown', locationCfg)
    local startingCoords = locationCfg.StartingCoords

    while Countdown do
        Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - startingCoords)

        if (distance > 30) or (IsEntityDead(playerPed)) then
            DoReset = true
            break
        end

        BccUtils.Misc.DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 0.5,
            _U('HoldOutBeforeLooting') .. ' ' .. tostring(Timer) .. ' ' .. _U('HoldOutBeforeLooting2'))
        if Timer <= 0 then
            Core.NotifyRightTip(_U('LootMarked'), 4000)
            break
        end
    end

    if DoReset then
        ResetRobbery()
        return
    end

    for _, lootCfg in pairs(locationCfg.LootLocations) do
        TriggerEvent('bcc-robbery:LootHandler', lootCfg)
    end
end)

AddEventHandler('bcc-robbery:Countdown', function(locationCfg)
    Timer = locationCfg.WaitBeforeLoot
    while Countdown do
        Wait(1000)
        Timer = Timer - 1
        if Timer <= 0 then
            Countdown = false
        end
    end
end)

AddEventHandler('bcc-robbery:LootHandler', function(lootCfg)
    math.randomseed(GetGameTimer()) --Create a new seed for math.random

    local lootGroup = BccUtils.Prompts:SetupPromptGroup()
    local lootPrompt = lootGroup:RegisterPrompt(_U('Rob'), Config.Keys.Loot, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })

    -- Minigame Config
    local cfg = {
        focus = true,                                     -- Should minigame take nui focus
        cursor = true,                                    -- Should minigame have cursor  (required for lockpick)
        maxattempts = Config.LockPick.MaxAttemptsPerLock, -- How many fail attempts are allowed before game over
        threshold = Config.LockPick.difficulty,           -- +- threshold to the stage degree (bigger number means easier)
        hintdelay = Config.LockPick.hintdelay,            --milliseconds delay on when the circle will shake to show lockpick is in the right position.
        stages = Config.LockPick.pins
    }

    if Config.LockPick.randomPins == true then
        cfg.stages = {
            {
                deg = math.random(0, 360) -- 0-360 degrees
            },
            {
                deg = math.random(0, 360) -- 0-360 degrees
            },
            {
                deg = math.random(0, 360) -- 0-360 degrees
            }
        }
    end

    while true do
        Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = #(playerCoords - lootCfg.LootCoordinates)

        if (distance > 30) or (IsEntityDead(playerPed)) then
            DoReset = true
            break
        end

        if distance < 6 then
            BccUtils.Misc.DrawText3D(lootCfg.LootCoordinates.x, lootCfg.LootCoordinates.y, lootCfg.LootCoordinates.z,
                _U('Robbery'))
        end

        if distance < 2 then
            lootGroup:ShowGroup(_U('Robbery'))
            if lootPrompt:HasCompleted() then
                MiniGame.Start('lockpick', cfg, function(result)
                    if result.unlocked then
                        TriggerServerEvent('bcc-robbery:RewardPayout', lootCfg)
                        Inmission = false
                    else
                        Core.NotifyRightTip(_U('PickFailed'), 4000)
                        Inmission = false
                    end
                end)
                break
            end
        end
    end
    if DoReset then
        ResetRobbery()
        return
    end
end)

local function LoadModel(hash, model)
    if not IsModelValid(hash) then
        return print('Invalid model:', model)
    end

    RequestModel(hash, false)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
end

AddEventHandler('bcc-robbery:EnemyPeds', function(location)
    local NpcCoords = location.EnemyNpcCoords
    local model = location.NpcModel
    local hash = joaat(model)
    local enemyPeds = {}

    LoadModel(hash, model)

    for k, coords in pairs(NpcCoords) do
        enemyPeds[k] = Citizen.InvokeNative(0xD49F9B0955C367DE, hash, coords.x, coords.y, coords.z, 0.0, true, false,
            false, false)                                                           -- CreatePed
        Citizen.InvokeNative(0x283978A15512B2FE, enemyPeds[k], true)                -- SetRandomOutfitVariation
        Citizen.InvokeNative(0xF166E48407BAC484, enemyPeds[k], PlayerPedId(), 0, 0) -- TaskCombatPed
        Citizen.InvokeNative(0x23f74c2fda6e7c61, 953018525, enemyPeds[k])           -- BlipAddForEntity
    end

    while true do
        Wait(1000)
        if DoReset then
            for _, ped in pairs(enemyPeds) do
                DeletePed(ped)
            end
            break
        end
    end
end)
