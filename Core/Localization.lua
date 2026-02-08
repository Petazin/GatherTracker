local addonName, addonTable = ...

addonTable.Localization = {}
local L = addonTable.Localization

-- Cache para nombres de items
local itemNameCache = {}

-- Strings de UI estáticos (Menús, Cabeceras)
L.UI = {
    ["Mining"] = "Minería",
    ["Herbalism"] = "Herboristería",
    ["Skinning"] = "Desuello",
    ["Collected"] = "Recolectado",
    ["Total"] = "Total",
}

-- Función wrapper para obtener nombres de items de forma segura y cacheada
function addonTable.GetItemName(itemID)
    if not itemID then return "Unknown" end
    
    if itemNameCache[itemID] then
        return itemNameCache[itemID]
    end

    local name = GetItemInfo(itemID)
    if name then
        itemNameCache[itemID] = name
        return name
    else
        return "Item " .. itemID -- Fallback si no está en caché aún
    end
end
