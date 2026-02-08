local addonName, addonTable = ...

addonTable.Collection = {}

-- Función para calcular el progreso de recolección de un nodo
-- Retorna: collectedCount, totalItems
function addonTable.Collection.GetNodeProgress(nodeData)
    local collected = 0
    local total = 0

    if not nodeData or not nodeData.items then
        return 0, 0
    end

    for _, itemID in ipairs(nodeData.items) do
        total = total + 1
        local count = GetItemCount(itemID, true) -- true incluye banco
        if count > 0 then
            collected = collected + 1
        end
    end

    return collected, total
end

-- Función para escanear una zona completa
function addonTable.Collection.ScanZone(mapID)
    local zoneData = addonTable.DB[mapID]
    if not zoneData then return {} end

    local results = {}
    for nodeName, data in pairs(zoneData.Nodes) do
        local collected, total = addonTable.Collection.GetNodeProgress(data)
        results[nodeName] = {
            collected = collected,
            total = total,
            percent = (total > 0) and (collected / total * 100) or 0
        }
    end
    return results
end
