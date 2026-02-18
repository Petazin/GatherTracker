local addonName, addonTable = ...

-- Estructura para datos externos (ATT, Manual, etc.)
addonTable.KnowledgeDB = {
    Recipes = {}
}

-- Diccionario de Items (Nombre -> ID)
addonTable.ItemLookup = {
}

-- Persisted Usage-Learned IDs (v2.6.12)
addonTable.UserItemIDs = {}

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
        ["Mena de adamantita"] = 23424,
        ["Mena de hierro vil"] = 22785,
        ["Mena de hierro vil"] = 22785,
        -- TBC Primal/Gems (Verified v2.6.12)
        ["Fuego primigenio"] = 21884,
        ["Aire primigenio"] = 22451,
        ["Tierra primigenia"] = 22452, -- Verified
        ["Agua primigenia"] = 21885,
        ["Maná primigenio"] = 22457,
        ["Vida primigenia"] = 21886,
        ["Sombra primigenia"] = 22456,
        ["Granate de sangre"] = 23095,
        ["Espesartita de llamas"] = 23096,
        ["Piedra lunar azur"] = 23097,
        ["Draenita dorada"] = 23099,
        ["Draenita de Sombras"] = 23098,
        ["Draenita de sombras"] = 23098,
        ["Peridoto intenso"] = 23079, -- Verified
        ["Diamante de fuego celeste"] = 25867,
        ["Diamante de tormenta de tierra"] = 25868,
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
        ["Fel Iron Ore"] = 22785,
        -- TBC Primal/Gems (v2.6.12 Verified)
        ["Primal Fire"] = 21884,
        ["Primal Air"] = 22451,
        ["Primal Earth"] = 22452,
        ["Primal Water"] = 21885,
        ["Primal Mana"] = 22457,
        ["Primal Life"] = 21886,
        ["Primal Shadow"] = 22456,
        ["Blood Garnet"] = 23095,
        ["Flame Spessarite"] = 23096,
        ["Azure Moonstone"] = 23097,
        ["Golden Draenite"] = 23099,
        ["Shadow Draenite"] = 23098,
        ["Deep Peridot"] = 23079,
        ["Skyfire Diamond"] = 25867,
        ["Earthstorm Diamond"] = 25868,
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

-- v2.6.10: Support esMX sharing esES data
if addonTable.StaticItemIDs["esES"] then
    addonTable.StaticItemIDs["esMX"] = addonTable.StaticItemIDs["esES"]
end
