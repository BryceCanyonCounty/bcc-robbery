-----------------------------------------------------
-- Robbery Location Configuration
-----------------------------------------------------
Locations = {
    {                                                               -- Valentine General Store
        Id = 1,                                                     --this has to be unique to each robbery
        StartingCoords = vector3(-322.36, 804.46, 117.88),          --coords you have to be near to start the robbery
        Distance = 5,                                               -- Distance from 'StartingCoords' to trigger the robbery
        EnemyNpcs = true,                                           --if true enemy npcs will spawn and attack the player
        NpcModel = 'a_m_m_huntertravelers_cool_01',                 --model of the enemy npc
        WaitBeforeLoot = 30,                                        --wait in seconds before player can loot 0 for none
        LootLocations = {                                           --This is the loot location setup, add as many as youd like
            {                                                       -- Upstairs
                LootCoordinates = vector3(-325.82, 797.02, 121.54), --coordinates of the loot box
                CashReward = math.random(50, 450),                  --amount of cash to reward
                GoldReward = math.random(1, 5),                     --amount of gold to reward
                RolReward = math.random(10, 50),                    --amount of rol to reward
                ItemRewards = {                                     --these are the items it will reward can add as many as youd like
                    {
                        name = 'iron',                              --name of the item in the database
                        label = 'Iron',                             --item label to notify player
                        count = math.random(1, 5),                  --the amount of the item to give
                    },
                    {
                        name = 'water',
                        label = 'water',
                        count = math.random(1, 5),
                    },
                },
            },
            {                                                       -- Downstairs
                LootCoordinates = vector3(-321.37, 806.94, 117.88), --coordinates of the loot box
                CashReward = math.random(50, 450),                  --amount of cash to reward
                GoldReward = math.random(1, 5),                     --amount of gold to reward
                RolReward = math.random(10, 50),                    --amount of rol to reward
                ItemRewards = {                                     --these are the items it will reward can add as many as youd like
                    {
                        name = 'iron',                              --the name of the item in the database
                        label = 'Iron',
                        count = math.random(1, 5),                  --amount to give
                    },
                },
            },
        },
        EnemyNpcCoords = { --coords where the enemy npcs will spawn add as many as youd like
            vector3(-323.81, 794.35, 117.89),
            vector3(-316.92, 795.39, 117.66),
        },
    },
    -----------------------------------------------------

    {                                                             -- Valentine Bank
        Id = 2,                                                   --this has to be unique to each robbery
        StartingCoords = vector3(-307.49, 778.03, 118.7),         --coords you have to be near to start the robbery
        Distance = 5,                                             -- Distance from 'StartingCoords' to trigger the robbery
        EnemyNpcs = true,                                         --if true enemy npcs will spawn and attack the player
        NpcModel = 'a_m_m_huntertravelers_cool_01',               --model of the enemy npc
        WaitBeforeLoot = 30,                                      --wait in seconds before player can loot 0 for none
        LootLocations = {                                         --This is the loot location setup, add as many as youd like
            {
                LootCoordinates = vector3(-301.89, 772.2, 118.7), --coordinates of the loot box
                CashReward = math.random(50, 1000),               --amount of cash to reward set 0 for none
                GoldReward = math.random(1, 5),                   --amount of gold to reward
                RolReward = math.random(10, 50),                  --amount of rol to reward
                ItemRewards = {                                   --these are the items it will reward can add as many as youd like
                    {
                        name = 'iron',                            --name of the item in db
                        label = 'Iron',
                        count = math.random(1, 5),                --amount to give
                    },
                },
            },
        },
        EnemyNpcCoords = { --coords where the enemy npcs will spawn add as many as youd like
            vector3(-323.81, 794.35, 117.89),
            vector3(-316.92, 795.39, 117.66),
        },
    },
    -----------------------------------------------------
}
