local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()

local discord = BccUtils.Discord.setup(Config.Webhook.URL, Config.Webhook.Title, Config.Webhook.Avatar)

local policeAlert = exports['bcc-job-alerts']:RegisterAlert(Config.Alerts.Police)

-- Cooldown Handler thanks to Byte
local cooldowns = {}
Core.Callback.Register('bcc-robbery:CheckCooldown', function(source, cb, location)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local id = location.Id

    if cooldowns[id] then
        local minutes = (Config.RobberyCooldown * 60)
        if os.difftime(os.time(), cooldowns[id]) >= minutes then --Check if the cooldown has expired
            cooldowns[id] = os.time()                            -- If expired, store the current time
            cb(true)
            policeAlert:SendAlert(src)
        else --Robbery is on cooldown
            cb(false)
        end
    else                          --Robbery is not on cooldown
        cooldowns[id] = os.time() --Store the current time
        cb(true)
        policeAlert:SendAlert(src)
    end
end)

RegisterServerEvent('bcc-robbery:RewardPayout', function(lootCfg)
    local src = source
    local user = Core.getUser(src)
    if not user then return end
    local character = user.getUsedCharacter
    local cash = lootCfg.CashReward
    local gold = lootCfg.GoldReward
    local rol = lootCfg.RolReward

    if cash > 0 then
        character.addCurrency(0, cash)
    end

    if gold > 0 then
        character.addCurrency(1, gold)
    end

    if rol > 0 then
        character.addCurrency(2, rol)
    end

    Core.NotifyRightTip(source,
        _U('youTook') .. '$~o~' .. cash .. '~q~, ~o~' .. gold .. '~q~ gold' .. ', ~o~' .. rol .. '~q~ rol', 5000)

    discord:sendMessage('Name: ' ..
        character.firstname .. ' ' .. character.lastname .. '\nIdentifier: ' .. character.identifier ..
        '\nReward: ' .. '$' .. tostring(cash) ..
        '\nReward: ' .. tostring(gold) .. ' gold' ..
        '\nReward: ' .. tostring(rol) .. ' rol')

    for _, reward in pairs(lootCfg.ItemRewards) do
        local canCarry = exports.vorp_inventory:canCarryItem(src, reward.name, reward.count)
        if canCarry then
            exports.vorp_inventory:addItem(src, reward.name, reward.count)
            Core.NotifyRightTip(src, _U('youTook') .. reward.count .. ' ' .. reward.label, 4000)

            discord:sendMessage('Name: ' ..
            character.firstname ..
            ' ' ..
            character.lastname ..
            '\nIdentifier: ' .. character.identifier .. '\nReward: ' .. reward.count .. ' ' .. reward.name)
        else
            Core.NotifyRightTip(src, _U('NoSpace'), 4000)
        end
    end
end)

Core.Callback.Register('bcc-robbery:RobberyCheck', function(source, cb)
    local src = source
    local user = Core.getUser(src)
    if not user then return cb(false) end
    local character = user.getUsedCharacter
    local charJob = character.job
    local hasJob = false
    local jobTable = Config.Jobs.Prohibited

    for _, job in ipairs(jobTable) do
        if job == charJob then
            hasJob = true
            break
        end
    end
    if hasJob then
        Core.NotifyRightTip(src, _U('WrongJob'), 4000)
        return cb(false)
    end

    local policeCount = 0
    for _, playerId in ipairs(GetPlayers()) do
        for _, job in ipairs(Config.Jobs.Law) do
            local player = Core.getUser(playerId)
            if player then
                local playerChar = player.getUsedCharacter
                if playerChar.job == job then
                    policeCount = policeCount + 1
                end
            end
        end
    end
    -- Check if there are enough police
    if policeCount < Config.Jobs.LawAmount then
        Core.NotifyRightTip(src, _U('NotEnoughPolice'), 4000)
        return cb(false)
    end
    cb(true)
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-robbery')
