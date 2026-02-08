local addonName, addonTable = ...

-- Estructura de Base de Datos Estática (Inspirada en ATT)
-- MapID -> Nodes -> NodeID -> Items
addonTable.DB = {
    [1448] = { -- Hellfire Peninsula
        ["Nodes"] = {
            ["Fel Iron Deposit"] = { -- Using string key for now as placeholder, ideally ID
                ["items"] = {
                    22785, -- Fel Iron Ore
                    22786, -- Mote of Fire
                    22787, -- Mote of Earth
                },
                ["type"] = "Mining",
            },
             ["Adamantite Deposit"] = {
                ["items"] = {
                    23424, -- Adamantite Ore
                    22786, -- Mote of Earth
                },
                ["type"] = "Mining",
            },
             ["Felweed"] = {
                ["items"] = {
                    22785, -- Felweed
                    22786, -- Mote of Life
                },
                ["type"] = "Herbalism",
            }
        }
    }
}

-- Fallback Database for Name -> ID resolution (fixes Cache Misses)
addonTable.StaticItemIDs = {
    ["esES"] = {
        -- Engineering / Schematics
        ["Madeja de tejido abisal"] = 21877,
        ["Batería de korio"] = 23786,
        ["Tubo de adamantita endurecida"] = 23783,
        ["Estabilizador de acero vil"] = 23781,
        ["Mena de hierro"] = 2772,
        ["Mena de korio"] = 23425,
        ["Mena de adamantita"] = 23424,
        ["Mena de hierro vil"] = 22785,
    },
    ["enUS"] = {
        -- Engineering / Schematics
        ["Netherweave Cloth"] = 21877,
        ["Khorium Power Core"] = 23786,
        ["Hardened Adamantite Tube"] = 23783,
        ["Felsteel Stabilizer"] = 23781,
        ["Iron Ore"] = 2772,
        ["Khorium Ore"] = 23425,
        ["Adamantite Ore"] = 23424,
        ["Fel Iron Ore"] = 22785,
    }
}

-- Base de Datos de Recetas (ID -> Materiales)
-- Esto permite importar recetas sin depender del caché ni del escaneo de tooltip.
-- Formato: [RecipeID] = { {itemID, quantity}, ... }
addonTable.RecipeDB = {
    -- Ingeniería
    [35582] = { -- Esquema: botas cohete Xtremo
        {21877, 8}, -- Madeja de tejido abisal
        {23786, 2}, -- Batería de korio
        {23783, 2}, -- Tubo de adamantita endurecida
        {23781, 4}, -- Estabilizador de acero vil
    },
}
