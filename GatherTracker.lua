print("GT DEBUG: Archivo Lua cargado.")
BINDING_HEADER_GATHERTRACKER = "GatherTracker"
BINDING_NAME_GATHERTRACKER_TOGGLE = "Activar/Desactivar Rastreo"

GatherTracker = LibStub("AceAddon-3.0"):NewAddon("GatherTracker", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

-- ============================================================================
-- 1. TABLAS DE DATOS Y CONSTANTES
-- ============================================================================

BINDING_HEADER_GATHERTRACKER = "GatherTracker"
BINDING_NAME_GATHERTRACKER_TOGGLE = "Alternar Rastreo"

local function GetName(id)
    local name = GetSpellInfo(id)
    return name or "Hechizo (" .. id .. ")"
end

local trackingMasterList = {
    minerals        = { icon = 136025, spellID = 2580,  type = "MINING" },
    herbs           = { icon = 133939, spellID = 2383,  type = "HERBALISM" },
    hidden          = { icon = 132320, spellID = 19885, type = "GENERAL" },
    beasts          = { icon = 132328, spellID = 1494,  type = "HUNTER" },
    dragonkin       = { icon = 134153, spellID = 19879, type = "HUNTER" },
    elementals      = { icon = 135861, spellID = 19880, type = "HUNTER" },
    undead          = { icon = 136142, spellID = 19884, type = "HUNTER" },
    demons          = { icon = 136217, spellID = 19878, type = "HUNTER" },
    giants          = { icon = 132275, spellID = 19882, type = "HUNTER" },
    humanoids       = { icon = 135942, spellID = 19883, type = "HUNTER" },
    humanoids_druid = { icon = 132328, spellID = 19883, type = "DRUID" },
    treasure        = { icon = 135725, spellID = 2481,  type = "DWARF" }
}

local resourceColors = {
    MINING    = "|cffC4C4C4", HERBALISM = "|cff1EFF00", GENERAL   = "|cffFFFF00",
    HUNTER    = "|cffFF5500", DRUID     = "|cffFF7C0A", DWARF     = "|cff0070DE",
}

local nodeKeywords = {
    -- Generic (Mining)
    ["Mena"] = "MINING", ["Veta"] = "MINING", ["Depósito"] = "MINING", ["Rica"] = "MINING",
    ["Ore"] = "MINING", ["Vein"] = "MINING", ["Deposit"] = "MINING", ["Rich"] = "MINING",
    ["Filón"] = "MINING", ["Filon"] = "MINING", -- Variaciones de Cobre
    
    -- Generic (Herbalism)
    ["Hierba"] = "HERBALISM", ["Flor"] = "HERBALISM", ["Loto"] = "HERBALISM", ["Champiñón"] = "HERBALISM",
    ["Herb"] = "HERBALISM", ["Flower"] = "HERBALISM", ["Lotus"] = "HERBALISM", ["Mushroom"] = "HERBALISM",
    
    -- Specific Herbs (Spanish - Classic/TBC)
    ["Flor de paz"] = "HERBALISM", ["Hoja de plata"] = "HERBALISM", ["Raíz de tierra"] = "HERBALISM",
    ["Marregal"] = "HERBALISM", ["Brezospina"] = "HERBALISM", ["Hierba cardenal"] = "HERBALISM",
    ["Acérita"] = "HERBALISM", ["Sangrerregia"] = "HERBALISM", ["Vidarraíz"] = "HERBALISM",
    ["Pálida"] = "HERBALISM", ["Mostacho de Khadgar"] = "HERBALISM", ["Espina de oro"] = "HERBALISM",
    ["Dientes de dragón"] = "HERBALISM", ["Soledad"] = "HERBALISM", ["Groms"] = "HERBALISM",
    ["Sansam"] = "HERBALISM", ["Musgo"] = "HERBALISM", ["Setelo"] = "HERBALISM", ["Capirote"] = "HERBALISM",
    ["Ensueño"] = "HERBALISM", ["Silversage"] = "HERBALISM", ["Salvia"] = "HERBALISM",
    ["Felweed"] = "HERBALISM", ["Vilhierba"] = "HERBALISM", ["Teropiña"] = "HERBALISM",
    ["Velada"] = "HERBALISM", ["Glory"] = "HERBALISM", ["Gloria"] = "HERBALISM", ["Netherbloom"] = "HERBALISM",
    ["Abisal"] = "HERBALISM", ["Pesadilla"] = "HERBALISM", ["Mana Thistle"] = "HERBALISM", ["Cardo"] = "HERBALISM",
    
    -- Chests
    ["Cofre"] = "DWARF", ["Chest"] = "DWARF", ["Caja"] = "DWARF", ["Crate"] = "DWARF"
}

-- Listas para menú (simplificado para ahorrar espacio, expandir si se necesita más detalle)
local trackingValues = { minerals = GetName(2580), herbs = GetName(2383) }
local hunterValues = { minerals = GetName(2580), herbs = GetName(2383), hidden = GetName(19885), beasts = GetName(1494), dragonkin = GetName(19879), elementals = GetName(19880), undead = GetName(19884), giants = GetName(19882), humanoids = GetName(19883), demons = GetName(19878) }
local druidValues = { minerals = GetName(2580), herbs = GetName(2383), humanoids_druid = GetName(19883) }

local classTrackingValues = trackingValues
local _, englishClass = UnitClass("player")
if englishClass == 'DRUID' then classTrackingValues = druidValues
elseif englishClass == 'HUNTER' then classTrackingValues = hunterValues end
local _, raceEn = UnitRace("player")
if raceEn == 'Dwarf' then classTrackingValues['treasure'] = GetName(2481) end

-- ============================================================================
-- 2. CONFIGURACIÓN DEL MENÚ
-- ============================================================================
local options = {
    name = 'GatherTracker', handler = GatherTracker, type = 'group',
    args = {
        header = { order = 1, type = "header", name = "Configuración General" },
        type1 = { order = 2, name = "Rastreo Primario", type = "select", values = classTrackingValues, get = 'GetType1', set = 'SetType1' },
        type2 = { order = 3, name = "Rastreo Secundario", type = "select", values = classTrackingValues, get = 'GetType2', set = 'SetType2' },
        castInterval = { order = 4, name = "Intervalo (seg)", type = "range", min = 2, max = 60, step = 1, get = 'GetCastInterval', set = 'SetCastInterval' },
        showFrame = { order = 5, name = "Mostrar Botón", type = "toggle", get = 'GetShowFrame', set = 'SetShowFrame' },
        soundEnabled = { order = 6, name = "Sonido al Detectar", type = "toggle", get = 'GetSoundEnabled', set = 'SetSoundEnabled' },
        
        headerAuto = { order = 10, type = "header", name = "Automatización" },
        autoSell = { order = 11, name = "Auto-Vender Grises", desc = "Vende automáticamente objetos grises al visitar un comerciante.", type = "toggle", get = 'GetAutoSell', set = 'SetAutoSell' },
        autoProf = { order = 12, name = "Auto-Detectar Profesión", desc = "Configura automáticamente Minerales/Hierbas al entrar.", type = "toggle", get = 'GetAutoProf', set = 'SetAutoProf' },
        
        headerProfile = { order = 20, type = "header", name = "Perfiles" },
        profile = LibStub("AceDBOptions-3.0"):GetOptionsTable("GatherTrackerDB"),
    }
}
-- Exponer opciones para validación y debug
GatherTracker.options = options

local defaults = {
    profile  = {
        type1 = "minerals", type2 = "herbs", castInterval = 2,
        showFrame = true, soundEnabled = false,
        autoSell = false, autoProf = true,
        pos = { point = "CENTER", x = 0, y = 0 },
    },
    global = {
        heatmap = {}, -- { [mapID] = { {x, y, count, type}, ... } }
        totalNodesFound = 0
    }
}

-- ============================================================================
-- 3. INICIALIZACIÓN
-- ============================================================================

function GatherTracker:OnInitialize()
    -- DB con soporte de Profiles global
    self.db = LibStub("AceDB-3.0"):New("GatherTrackerDB", defaults, true) 
    
    -- Configurar opciones de perfil correctamente
    options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GatherTracker', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('GatherTracker', 'GatherTracker')
    
    self:RegisterChatCommand('gtr', 'ChatCommand')
    self:RegisterChatCommand('gtrack', 'ChatCommand')
    
    -- Eventos Core
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Eventos Automatización
    self:RegisterEvent("MERCHANT_SHOW")
    
    -- Inicializar Historial Sesión
    self.sessionHistory = {}

    self:InitLDB()
    self.IS_RUNNING = false
    self:CreateGUI()

    -- Hook Tooltip
    if GameTooltip then
        GameTooltip:HookScript("OnShow", function(tt) self:ScanTooltip(tt) end)
    end
    
    local version = C_AddOns and C_AddOns.GetAddOnMetadata("GatherTracker", "Version") or GetAddOnMetadata("GatherTracker", "Version")
    print("|cff00ff00GatherTracker:|r v" .. (version or "Unknown") .. " cargado. (/gt opt)")
end

function GatherTracker:PLAYER_ENTERING_WORLD()
    self:CheckProfessions()
end

function GatherTracker:CheckProfessions()
    if not self.db.profile.autoProf then return end
    
    -- Detectar profesiones (API Classic/TBC varia, usamos bucle simple en skills)
    -- En TBC GetProfessions devuelve indices.
    local prof1, prof2 = GetProfessions()
    local hasMining, hasHerbalism = false, false
    
    local function CheckSkill(index)
        if not index then return end
        local name, _, _, _, _, _, skillID = GetProfessionInfo(index)
        if name == GetSpellInfo(2575) or name == "Minería" or name == "Mining" then hasMining = true end
        if name == GetSpellInfo(2366) or name == "Herboristería" or name == "Herbalism" then hasHerbalism = true end
    end
    
    CheckSkill(prof1)
    CheckSkill(prof2)
    
    if hasMining and not hasHerbalism then
        self.db.profile.type1 = "minerals"
        self.db.profile.type2 = "minerals" -- Solo mineria
        print("GT: Solo Minería detectada. Rastreo ajustado.")
    elseif hasHerbalism and not hasMining then
        self.db.profile.type1 = "herbs"
        self.db.profile.type2 = "herbs"
        print("GT: Solo Herboristería detectada. Rastreo ajustado.")
    elseif hasMining and hasHerbalism then
        self.db.profile.type1 = "minerals"
        self.db.profile.type2 = "herbs"
        print("GT: Híbrido detectado. Rastreo alternado.")
    end
end

function GatherTracker:MERCHANT_SHOW()
    if self.db.profile.autoSell then
        self:SellGrayItems()
    end
end

function GatherTracker:SellGrayItems()
    local count = 0
    for bag = 0, 4 do
        local numSlots
        if C_Container and C_Container.GetContainerNumSlots then
            numSlots = C_Container.GetContainerNumSlots(bag)
        else
            numSlots = GetContainerNumSlots(bag)
        end
        
        for slot = 1, numSlots do
            local quality, link
            if C_Container and C_Container.GetContainerItemInfo then
                local info = C_Container.GetContainerItemInfo(bag, slot)
                if info then
                    quality = info.quality
                    link = info.hyperlink
                end
            else
                 _, _, _, quality, _, _, link = GetContainerItemInfo(bag, slot)
            end

            if link and quality == 0 then 
                if C_Container and C_Container.UseContainerItem then
                    C_Container.UseContainerItem(bag, slot)
                else
                    UseContainerItem(bag, slot)
                end
                count = count + 1
            end
        end
    end
    if count > 0 then
        print("|cff00ff00GT:|r Vendidos " .. count .. " items basura.")
    end
end

-- ============================================================================
-- 4. GUI & HUD
-- ============================================================================

function GatherTracker:CreateGUI()
    if self.frame then return end

    local f = CreateFrame("Button", "GatherTrackerFrame", UIParent, "BackdropTemplate")
    f:SetSize(40, 40)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:EnableMouseWheel(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)

    f.icon = f:CreateTexture(nil, "BACKGROUND")
    f.icon:SetAllPoints()
    f.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    f.border:SetAllPoints()
    f.border:SetVertexColor(1, 0, 0)

    f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cooldown:SetAllPoints()

    f:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        GatherTracker.db.profile.pos = { point = point, x = xOfs, y = yOfs }
    end)

    f:SetScript("OnClick", function(self, button)
        if IsShiftKeyDown() then
            if button == "LeftButton" then GatherTracker:AnnounceLastNode() end
        else
            if button == "LeftButton" then
                GatherTracker:ToggleTracking()
            elseif button == "RightButton" then
                LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
            end
        end
    end)

    f:SetScript("OnMouseWheel", function(self, delta)
        local current = GatherTracker:GetCastInterval()
        local newTime = current + delta
        if newTime < 2 then newTime = 2 end
        if newTime > 60 then newTime = 60 end
        GatherTracker:SetCastInterval(nil, newTime)
        GatherTracker:UpdateTooltip(self)
    end)

    f:SetScript("OnEnter", function(self) GatherTracker:UpdateTooltip(self) end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.frame = f
    self:RestorePosition()
    self:UpdateGUI()
end

function GatherTracker:UpdateTooltip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("GatherTracker")
    
    if GatherTracker.IS_RUNNING then
        GameTooltip:AddLine("Estado: |cff00ff00ACTIVO|r", 1, 1, 1)
    else
        GameTooltip:AddLine("Estado: |cffff0000PAUSADO|r", 1, 1, 1)
    end
    
    GameTooltip:AddDoubleLine("Intervalo:", "|cffFFFF00" .. GatherTracker:GetCastInterval() .. " seg|r")
    GameTooltip:AddDoubleLine("Nodos Totales (Global):", self.db.global.totalNodesFound or 0)
    GameTooltip:AddLine(" ")
    
    if #self.sessionHistory > 0 then
        GameTooltip:AddLine("Historial Reciente:", 0.5, 0.8, 1)
        local now = GetTime()
        for i, node in ipairs(self.sessionHistory) do
            if i > 5 then break end
            local diff = math.floor(now - node.time)
            local color = resourceColors[node.type] or "|cffFFFFFF"
            GameTooltip:AddDoubleLine(color .. node.name .. "|r", diff .. "s", 1, 1, 1, 0.7, 0.7, 0.7)
        end
        GameTooltip:AddLine(" ")
    end

    GameTooltip:AddLine("|cffFFFFFFClic Izq:|r Activar/Pausar")
    GameTooltip:AddLine("|cffFFFFFFShift+Clic:|r Anunciar")
    GameTooltip:AddLine("|cffFFFFFFAlt+Arrastrar:|r Mover")
    GameTooltip:Show()
end

function GatherTracker:RestorePosition()
    if not self.frame then return end
    local pos = self.db.profile.pos
    if pos then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    else
        self.frame:SetPoint("CENTER")
    end
end

function GatherTracker:UpdateGUI()
    if not self.frame then return end
    if self.db.profile.showFrame then self.frame:Show() else self.frame:Hide() return end

    if currentTexture then
        self.frame.icon:SetTexture(currentTexture)
        self.frame.icon:SetDesaturated(false)
    else
        self.frame.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        self.frame.icon:SetDesaturated(true)
    end

    if self.IS_RUNNING then
        self.frame.border:SetVertexColor(0, 1, 0)
        self.frame.cooldown:SetCooldown(GetTime(), self:GetCastInterval())
    else
        self.frame.border:SetVertexColor(1, 0, 0)
        self.frame.icon:SetDesaturated(true)
    end
end

-- ============================================================================
-- 5. LÓGICA DE DETECCIÓN Y PERSISTENCIA
-- ============================================================================

function GatherTracker:ScanTooltip(tt)
    -- Filter: Strict check. Only scan tooltips owned by the Minimap.
    local owner = tt:GetOwner()
    if not owner or owner ~= Minimap then return end

    local line1 = _G[tt:GetName() .. "TextLeft1"]
    if not line1 then return end
    local text = line1:GetText()
    if not text then return end
    
    local nodeType = nil
    for keyword, typeVal in pairs(nodeKeywords) do
        if string.find(text, keyword) then
            nodeType = typeVal
            break
        end
    end
    
    if nodeType then
        self:RegisterNode(text, nodeType)
    end
end

function GatherTracker:RegisterNode(name, typeVal)
    local now = GetTime()
    
    -- Snapshot de la posicion del jugador AL MOMENTO DE DETECTAR
    local mapID = C_Map.GetBestMapForUnit("player")
    local x, y = 0, 0
    if mapID then
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then x, y = pos.x, pos.y end
    end

    -- Intentamos obtener el Layer (Para Classic/TBC esto suele requerir librerías, dejamos placeholder)
    local layer = self:GetPlayerLayer()

    if #self.sessionHistory > 0 then
        local last = self.sessionHistory[1]
        -- Si es el mismo nodo (mismo nombre) y hace poco tiempo...
        if last.name == name and (now - last.time) < 10 then
            last.time = now
            return
        end
    end
    
    -- Guardar coordenadas y layer en el historial
    table.insert(self.sessionHistory, 1, { name = name, type = typeVal, time = now, mapID = mapID, x = x, y = y, layer = layer })
    if #self.sessionHistory > 20 then table.remove(self.sessionHistory) end
    
    self:SaveToGlobalDB(name, typeVal, layer)
    
    if self.db.profile.soundEnabled then
        PlaySound(8959)
    end
end

function GatherTracker:SaveToGlobalDB(name, typeVal, layer)
    -- Contadores
    if not self.db.global.totalNodesFound then self.db.global.totalNodesFound = 0 end
    self.db.global.totalNodesFound = self.db.global.totalNodesFound + 1
    
    -- Mapa de Calor (Coordenadas)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return end
    
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return end
    local x, y = pos.x, pos.y
    
    if not self.db.global.heatmap[mapID] then self.db.global.heatmap[mapID] = {} end
    
    -- Simplificación: Solo guardamos, sin agrupar por distancia para ahorrar CPU ahora.
    -- En V2.0 hacer clustering.
    table.insert(self.db.global.heatmap[mapID], { x = x, y = y, type = typeVal, time = time(), layer = layer })
end

function GatherTracker:GetPlayerLayer()
    -- Nota: En Classic/TBC, obtener el Layer real requiere analizar GUIDs de NPCs cercanos (LibLayered).
    -- Por ahora, devolvemos ID de instancia de mapa como aproximación básica o nil.
    local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
    return instanceID or 0
end

function GatherTracker:AnnounceLastNode()
    if #self.sessionHistory == 0 then print("GT: No hay nodos recientes."); return end
    local node = self.sessionHistory[1]
    local msg = "GatherTracker: Encontrado [" .. node.name .. "] hace " .. math.floor(GetTime() - node.time) .. "s."
    if IsInGroup() then SendChatMessage(msg, IsInRaid() and "RAID" or "PARTY") else print(msg) end
end

-- TomTom integration removed by user request

-- ============================================================================
-- 6. LDB, CONTROL TIMER Y COREADDON
-- ============================================================================

function GatherTracker:InitLDB()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    if LDB then
        self.ldbObj = LDB:NewDataObject("GatherTracker", {
            type = "launcher",
            icon = 136025,
            OnClick = function(_, button)
                if button == "RightButton" then LibStub("AceConfigDialog-3.0"):Open("GatherTracker") else GatherTracker:ToggleTracking() end
            end,
            OnTooltipShow = function(tt)
                tt:AddLine("GatherTracker")
                tt:AddLine("Clic: Activar | Der: Opciones")
            end,
        })
    end
end

function GatherTracker:ToggleTracking()
    if self.IS_RUNNING then self:StopTimer() else self:StartTimer() end
end

function GatherTracker:StartTimer()
    print('|cff00ff00GT:|r Iniciado. Intervalo: ' .. self:GetCastInterval() .. 's');
    self.trackingTimer = self:ScheduleRepeatingTimer('TimerFeedback', self:GetCastInterval())
    self.IS_RUNNING = true
    self:UpdateGUI()
end

function GatherTracker:StopTimer()
    print('|cffff0000GT:|r Detenido.');
    self:CancelTimer(self.trackingTimer);
    self.IS_RUNNING = false
    self:UpdateGUI()
end

function GatherTracker:MINIMAP_UPDATE_TRACKING() self:UpdateGUI() end
function GatherTracker:PLAYER_REGEN_DISABLED() if self.db.profile.showFrame then self.frame:SetAlpha(0.3) end end
function GatherTracker:PLAYER_REGEN_ENABLED() if self.db.profile.showFrame then self.frame:SetAlpha(1.0) self.frame:Show() end end

function GatherTracker:ChatCommand(input)
    if not input or input:trim() == "" then 
        self:ToggleTracking()
    elseif input:trim() == 'opt' then 
        LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
    elseif input:trim() == 'reset' then
        self.db.profile.pos = { point = "CENTER", x = 0, y = 0 }
        self:RestorePosition()
        self:UpdateGUI()
        print("GT: Posición restablecida al centro.")
    end
end

function GatherTracker:TimerFeedback()
    if UnitAffectingCombat("player") or UnitChannelInfo("player") or UnitCastingInfo("player") or UnitIsDeadOrGhost("player") then return end

    local type1Key = self:GetType1()
    local type2Key = self:GetType2()
    if not type1Key or not trackingMasterList[type1Key] then type1Key = "minerals" end
    if not type2Key or not trackingMasterList[type2Key] then type2Key = "herbs" end

    local targetKey = nil
    local isType1Active = self:IsTrackingActive(trackingMasterList[type1Key].spellID)
    if not isType1Active then targetKey = type1Key else targetKey = type2Key end

    local spellID = trackingMasterList[targetKey].spellID
    local iconID = trackingMasterList[targetKey].icon
    local success = self:SetTrackingBySpellID(spellID, iconID)
    
    if success then C_Timer.After(0.2, function() self:UpdateGUI() end) end
end

-- ============================================================================
-- 7. GETTERS Y SETTERS
-- ============================================================================

function GatherTracker:SetTrackingBySpellID(spellID, expectedIcon)
    local count = C_Minimap.GetNumTrackingTypes()
    local spellName = GetSpellInfo(spellID)
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name = info.name or info
        if (spellName and name == spellName) then C_Minimap.SetTracking(i, true) return true end
    end
    return false
end

function GatherTracker:IsTrackingActive(spellID)
    local spellName = GetSpellInfo(spellID)
    if not spellName then return false end
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name, active = info.name or info, info.active
        if name == spellName and active then return true end
    end
    return false
end

function GatherTracker:GetActiveTrackingTexture()
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do local info = C_Minimap.GetTrackingInfo(i) if info.active then return info.texture end end
    return nil
end

-- Accesors
function GatherTracker:GetCastInterval() return tonumber(self.db.profile.castInterval) or 2 end
function GatherTracker:SetCastInterval(info, val) self.db.profile.castInterval = val if self.IS_RUNNING then self:StopTimer() self:StartTimer() end end
function GatherTracker:GetType1() return self.db.profile.type1 end
function GatherTracker:SetType1(info, val) self.db.profile.type1 = val end
function GatherTracker:GetType2() return self.db.profile.type2 end
function GatherTracker:SetType2(info, val) self.db.profile.type2 = val end
function GatherTracker:GetShowFrame() return self.db.profile.showFrame end
function GatherTracker:SetShowFrame(info, val) self.db.profile.showFrame = val self:UpdateGUI() end
function GatherTracker:GetSoundEnabled() return self.db.profile.soundEnabled end
function GatherTracker:SetSoundEnabled(info, val) self.db.profile.soundEnabled = val end
function GatherTracker:GetAutoSell() return self.db.profile.autoSell end
function GatherTracker:SetAutoSell(info, val) self.db.profile.autoSell = val end
function GatherTracker:GetAutoProf() return self.db.profile.autoProf end
function GatherTracker:SetAutoProf(info, val) self.db.profile.autoProf = val end
