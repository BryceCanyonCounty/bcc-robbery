--Variables
Inmission = false
local robberyenable = false


----- Registering Command To enable and disable robberies ----
RegisterCommand(Config.RobberyCommand, function()
    TriggerServerEvent('bcc-robbery:JobCheck')
end)

--Event the serv will trigger if the player is not a restricted job
RegisterNetEvent('bcc-robbery:RobberyEnabler', function()
    if not robberyenable then
        robberyenable = true
        VORPcore.NotifyRightTip(Config.Language.RobberyEnable, 4000)
    else
        robberyenable = false
        VORPcore.NotifyRightTip(Config.Language.RobberyDisable, 4000)
    end
end)

----- Thread to trigger the events -----
Citizen.CreateThread(function()
    for k, v in pairs(Config.Robberies) do
        TriggerEvent('bcc-robbery:MainHandler', v)
    end
end)

------ Main Event Handler Triggers the robberies ------
AddEventHandler('bcc-robbery:MainHandler', function(v)
    while true do
        Citizen.Wait(200)
        if robberyenable then
            local plc = GetEntityCoords(PlayerPedId())
            if GetDistanceBetweenCoords(v.StartingCoords.x, v.StartingCoords.y, v.StartingCoords.z, plc.x, plc.y, plc.z) < 5 then
                while true do
                    Citizen.Wait(5)
                    if GetDistanceBetweenCoords(v.StartingCoords.x, v.StartingCoords.y, v.StartingCoords.z, plc.x, plc.y, plc.z) > 5 then break end
                    if not Inmission then
                        if IsPedShooting(PlayerPedId()) then
                            TriggerServerEvent('bcc-robbery:ServerCooldownCheck', v.Id, v)
                            Wait(5000) break
                        end
                    end
                end
            end
        end
    end
end)

---------- Robbery Setup -----------
RegisterNetEvent('bcc-robbery:RobberyHandler', function(v)
    Inmission = true
    TriggerEvent('bcc-robbery:DeadCheck', v.StartingCoords)
    VORPcore.NotifyRightTip(Config.Language.RobberyStart, 4000)

    if v.EnemyNpcs then
        TriggerEvent('bcc-robbery:EnemyPeds', v.EnemyNpcCoords)
    end

    local waittimer = v.WaitBeforeLoot
    while true do
        Citizen.Wait(10)
        local pl = GetEntityCoords(PlayerPedId())

        if PlayerDead then break end

        waittimer = waittimer - 20
        local roundedtimer = waittimer / 60000
        local rounded2 = (math.floor(roundedtimer * 100) / 100)

        DrawText3D(pl.x, pl.y, pl.z, Config.Language.HoldOutBeforeLooting .. ' ' .. tostring(rounded2) .. ' ' .. Config.Language.HoldOutBeforeLooting2)
        if waittimer <= 0 then
            VORPcore.NotifyRightTip(Config.Language.LootMarked, 4000) break
        end
    end

    if PlayerDead then
        Inmission = false
        VORPcore.NotifyRightTip(Config.Language.RobberyFail, 4000)
        Wait(5000)
        PlayerDead = false return
    end


    for k, e in pairs(v.LootLocations) do
        TriggerEvent('bcc-robbery:LootHandler', e)
    end
end)

---------- Loot Locations Setup ---------
AddEventHandler('bcc-robbery:LootHandler', function(e)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup() --registers a prompt group using vorp_utils
    local firstprompt = PromptGroup:RegisterPrompt(Config.Language.Rob, 0x760A9C6F, 1, 1, true, 'hold', {timedeventhash = "MEDIUM_TIMED_EVENT"})
    while true do
        Citizen.Wait(5)
        if PlayerDead then break end


        local plc = GetEntityCoords(PlayerPedId())
        
        local dist = GetDistanceBetweenCoords(plc.x, plc.y, plc.z, e.LootCoordinates.x, e.LootCoordinates.y, e.LootCoordinates.z, true)
        if dist < 6 then
            DrawText3D(e.LootCoordinates.x, e.LootCoordinates.y, e.LootCoordinates.z, Config.Language.Robbery)
        end
        if dist < 2 then
            PromptGroup:ShowGroup(Config.Language.Robbery)
            if firstprompt:HasCompleted() then

                local result = exports['lockpick']:startLockpick() --starts the lockpick and sets result to equal the result will print true if done right false if failed
                if result then
                    --Trigger event to add items
                    if e.CashReward > 0 then
                        TriggerServerEvent('bcc-robbery:CashPayout', e.CashReward)
                    end
                    TriggerServerEvent('bcc-robbery:ItemsPayout', e)
                    Inmission = false break
                else
                    VORPcore.NotifyRightTip(Config.Language.PickFailed, 4000)
                    Inmission = false break
                end
            end
        end
    end
end)