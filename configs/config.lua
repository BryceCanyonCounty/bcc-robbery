-----------------------------------------------------
-- Robbery Main Configuration
-----------------------------------------------------
Config = {}

-- Set Language
Config.defaultlang = 'en_lang'
-----------------------------------------------------

Config.Keys = {
    Loot = 0x760A9C6F, -- [G]
}
-----------------------------------------------------

-- Discord Webhook Configuration
Config.Webhook = {
    URL = '',
    Title = 'BCC-Robbery',
    Avatar = ''
}
-----------------------------------------------------

Config.RobberyCommand = 'robbery' --command to enter to enable robberies
-----------------------------------------------------

Config.RobberyCooldown = 15 -- Time in minutes before location can be robbed again
-----------------------------------------------------

Config.Jobs = {
    Law = { 'police', 'sheriff' }, -- Jobs that count as law
    LawAmount = 1, -- Minimum number of law required on server to start a robbery
    Prohibited = { 'police', 'sheriff' } -- Jobs that will not be able to do robberies
}
-----------------------------------------------------

--Lockpicking setup
Config.LockPick = {
    MaxAttemptsPerLock = 3,
    lockpickitem = 'lockpick',
    difficulty = 10,
    hintdelay = 500,
    pins = { -- hardcoded pins, if randomPins set to true, then this will be ignored.
        {
            deg = 25 -- 0-360 degrees
        },
        {
            deg = 0 -- 0-360 degrees
        },
        {
            deg = 300 -- 0-360 degrees
        }
    },
    randomPins = true --If random is set to True, then pins above will be ignored.
}
-----------------------------------------------------

Config.Alerts = {
    Police = {
        name = 'bcc-robbery-police', --The name of the alert
        command = '', -- the command, this is what players will use with /
        message = 'Robbery In Progress!', -- Message to show to the police
        messageTime = 40000, -- Time the message will stay on screen (miliseconds)
        jobs = {'police', 'sheriff'}, -- Job the alert is for
        jobgrade =
        {
            police = {0,1,2,3},
            sheriff = {0,1,2,3},
        }, -- What grades the alert will effect
        icon = 'star', -- The icon the alert will use
        color = 'COLOR_GOLD', -- The color of the icon / https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/colours
        texturedict = 'generic_textures', --https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/menu_textures
        hash = -1282792512, -- The radius blip
        radius = 40.0, -- The size of the radius blip
        blipTime = 60000, -- How long the blip will stay for the job (miliseconds)
        blipDelay = 5000, -- Delay time before the job is notified (miliseconds)
        originText = '', -- Text displayed to the user who enacted the command
        originTime = 0 -- The time the origintext displays (miliseconds)
    },
}