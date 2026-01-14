GatherTracker = LibStub("AceAddon-3.0"):NewAddon("GatherTracker", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0")

-- ============================================================================
-- 1. TABLAS DE DATOS
-- ============================================================================
local function GetName(id)
    local name = GetSpellInfo(id)
    return name or "Hechizo Desconocido (" .. id .. ")"
end
local trackingMasterList = {
    minerals        = { icon = 136025, spellID = 2580 },
    herbs           = { icon = 133939, spellID = 2383 },
    hidden          = { icon = 132320, spellID = 19885 },
    beasts          = { icon = 132328, spellID = 1494 },
    dragonkin       = { icon = 134153, spellID = 19879 },
    elementals      = { icon = 135861, spellID = 19880 },
    undead          = { icon = 136142, spellID = 19884 },
    demons          = { icon = 136217, spellID = 19878 },
    giants          = { icon = 132275, spellID = 19882 },
    humanoids       = { icon = 135942, spellID = 19883 },
    humanoids_druid = { icon = 132328, spellID = 19883 },
    treasure        = { icon = 135725, spellID = 2481 }
}

-- Listas para menú
local trackingValues = { minerals = GetName(2580), herbs = GetName(2383) }
local hunterValues = {
    minerals = GetName(2580), herbs = GetName(2383), hidden = GetName(19885),
    beasts = GetName(1494), dragonkin = GetName(19879), elementals = GetName(19880),
    undead = GetName(19884), giants = GetName(19882), humanoids = GetName(19883),
    demons = GetName(19878),
}
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
        header = { order = 1, type = "header", name = "Configuración de Rastreo" },
        type1 = { order = 2, name = "Rastreo Primario", type = "select", values = classTrackingValues, get = 'GetType1', set = 'SetType1' },
        type2 = { order = 3, name = "Rastreo Secundario", type = "select", values = classTrackingValues, get = 'GetType2', set = 'SetType2' },
        castInterval = { order = 4, name = "Intervalo (segundos)", type = "range", min = 2, max = 60, step = 1, get = 'GetCastInterval', set = 'SetCastInterval', width = "full" },
        showFrame = { order = 5, name = "Mostrar Botón Flotante", type = "toggle", get = 'GetShowFrame', set = 'SetShowFrame', width = "full" },
    }
}

local defaults = {
    profile  = {
        type1 = "minerals", type2 = "herbs", castInterval = 2,
        showFrame = true,
        pos = { point = "CENTER", x = 0, y = 0 }
    }
}

-- ============================================================================
-- 3. SISTEMA DE INTERFAZ GRÁFICA (GUI)
-- ============================================================================

function GatherTracker:CreateGUI()
    if self.frame then return end

    local f = CreateFrame("Button", "GatherTrackerFrame", UIParent, "BackdropTemplate")
    f:SetSize(40, 40)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:EnableMouseWheel(true) -- Habilitar Rueda del Ratón
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)

    -- Fondo e Icono
    f.icon = f:CreateTexture(nil, "BACKGROUND")
    f.icon:SetAllPoints()
    f.icon:SetTexture(GetTrackingTexture() or 134400)

    -- Borde
    f.border = f:CreateTexture(nil, "OVERLAY")
    f.border:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    f.border:SetAllPoints()
    f.border:SetVertexColor(1, 0, 0)

    f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
    f.cooldown:SetAllPoints()

    -- Arrastrar con ALT
    f:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        GatherTracker.db.profile.pos = { point = point, x = xOfs, y = yOfs }
    end)

    -- Clics
    f:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            GatherTracker:ToggleTracking()
        elseif button == "RightButton" then
            LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
        end
    end)

    -- Scroll (Rueda del Ratón) para cambiar tiempo
    f:SetScript("OnMouseWheel", function(self, delta)
        local current = GatherTracker:GetCastInterval()
        local newTime = current + delta -- Sube o baja 1 segundo
        
        -- Límites (Mínimo 2s, Máximo 60s)
        if newTime < 2 then newTime = 2 end
        if newTime > 60 then newTime = 60 end

        GatherTracker:SetCastInterval(nil, newTime)
        GatherTracker:UpdateTooltip(self) -- Actualizar texto visualmente
    end)

    -- Tooltip
    f:SetScript("OnEnter", function(self) GatherTracker:UpdateTooltip(self) end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.frame = f
    self:RestorePosition()
    self:UpdateGUI()
end

-- Función auxiliar para refrescar el tooltip dinámicamente
function GatherTracker:UpdateTooltip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("GatherTracker")
    
    if GatherTracker.IS_RUNNING then
        GameTooltip:AddLine("Estado: |cff00ff00ACTIVO|r", 1, 1, 1)
    else
        GameTooltip:AddLine("Estado: |cffff0000PAUSADO|r", 1, 1, 1)
    end
    
    GameTooltip:AddLine(" ")
    -- Mostramos el tiempo actual en amarillo destacado
    GameTooltip:AddDoubleLine("Intervalo:", "|cffFFFF00" .. GatherTracker:GetCastInterval() .. " seg|r")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffFFFFFFClic Izq:|r Activar/Pausar")
    GameTooltip:AddLine("|cffFFFFFFRueda:|r Ajustar Tiempo (+/-)")
    GameTooltip:AddLine("|cffFFFFFFClic Der:|r Menú Opciones")
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

-- Función auxiliar para obtener la textura del rastreo activo
function GatherTracker:GetActiveTrackingTexture()
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name, texture, active
        if type(info) == "table" then
            name = info.name
            texture = info.texture
            active = info.active
        else
            -- Fallback
            name, texture, active = GetTrackingInfo(i) -- Antigua global o C_Minimap multiple args
        end

        if active then
            return texture
        end
    end
    return nil
end

function GatherTracker:UpdateGUI()
    if not self.frame then return end
    
    if self.db.profile.showFrame then self.frame:Show() else self.frame:Hide() return end

    local currentTexture = self:GetActiveTrackingTexture()
    if currentTexture then
        self.frame.icon:SetTexture(currentTexture)
        self.frame.icon:SetDesaturated(false)
    else
        self.frame.icon:SetTexture(134400) -- Interrogación
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
-- 4. FUNCIONES PRINCIPALES
-- ============================================================================

function GatherTracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GatherTrackerCharDB", defaults, true)
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GatherTracker', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('GatherTracker', 'GatherTracker')
    
    self:RegisterChatCommand('gt', 'ChatCommand')
    
    -- Registrar evento para actualizar icono automáticamente
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    
    if not self.db.profile.type1 then self.db.profile.type1 = "minerals" end
    if not self.db.profile.type2 then self.db.profile.type2 = "herbs" end
    if not self.db.profile.castInterval then self.db.profile.castInterval = 2 end
    
    GatherTracker.IS_RUNNING = false
    self:CreateGUI()
    local version = C_AddOns and C_AddOns.GetAddOnMetadata("GatherTracker", "Version") or GetAddOnMetadata("GatherTracker", "Version")
    print("|cff00ff00GatherTracker:|r v" .. (version or "Unknown") .. " cargado (TBC).")
end

function GatherTracker:MINIMAP_UPDATE_TRACKING()
    self:UpdateGUI()
end

function GatherTracker:ChatCommand(input)
    if not input or input:trim() == "" then
        self:ToggleTracking()
    elseif input:trim() == 'opt' then
        LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
    end
end

function GatherTracker:ToggleTracking()
    if self.IS_RUNNING then 
        self:StopTimer()
        self.IS_RUNNING = false 
    else 
        self:StartTimer()
        self.IS_RUNNING = true 
    end
    self:UpdateGUI()
end

function GatherTracker:StartTimer()
    print('|cff00ff00TS:|r Iniciado. Intervalo: ' .. self:GetCastInterval() .. 's');
    self.trackingTimer = self:ScheduleRepeatingTimer('TimerFeedback', self:GetCastInterval())
    self.IS_RUNNING = true
    self:UpdateGUI()
end

function GatherTracker:StopTimer()
    print('|cffff0000TS:|r Detenido.');
    self:CancelTimer(self.trackingTimer);
    self.IS_RUNNING = false
    self:UpdateGUI()
end

function GatherTracker:SetTrackingBySpellID(spellID, expectedIcon)
    local count = C_Minimap.GetNumTrackingTypes()
    local spellName = GetSpellInfo(spellID)
    
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name, texture, active
        
        if type(info) == "table" then
            name = info.name
            texture = info.texture
        else
            -- Fallback por si acaso en alguna version retorna multiples valores
            name = info
        end

        -- 1. Intentar por Nombre
        if spellName and name == spellName then
            C_Minimap.SetTracking(i, true)
            return true
        end

        -- 2. Intentar por Icono/Textura
        if expectedIcon and texture == expectedIcon then
            C_Minimap.SetTracking(i, true)
            return true
        end
    end
    return false
end

function GatherTracker:IsTrackingActive(spellID)
    local spellName = GetSpellInfo(spellID)
    if not spellName then return false end
    
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name, active
        if type(info) == "table" then
            name = info.name
            active = info.active
        else
            -- Fallback api antigua
            name, _, active = info, select(3, C_Minimap.GetTrackingInfo(i))
        end

        if name == spellName and active then
            return true
        end
    end
    return false
end

function GatherTracker:TimerFeedback()
    if UnitAffectingCombat("player") or UnitChannelInfo("player") or UnitCastingInfo("player") or UnitIsDeadOrGhost("player") then
        return 
    end

    local type1Key = self:GetType1()
    local type2Key = self:GetType2()

    if not type1Key or not trackingMasterList[type1Key] then type1Key = "minerals" end
    if not type2Key or not trackingMasterList[type2Key] then type2Key = "herbs" end

    -- Lógica de conmutación basada en qué está activo realmente
    local targetKey = nil
    
    -- Verificamos si el TIPO 1 (Minerales) está activo
    local isType1Active = self:IsTrackingActive(trackingMasterList[type1Key].spellID)

    if not isType1Active then
        -- Si Type1 NO está activo -> Activarlo
        targetKey = type1Key
    else
        -- Si Type1 SI está activo -> Cambiar a Type2
        targetKey = type2Key
    end

    local spellID = trackingMasterList[targetKey].spellID
    local iconID = trackingMasterList[targetKey].icon
    
    -- Usar C_Minimap.SetTracking con lógica robusta
    local success = self:SetTrackingBySpellID(spellID, iconID)
    
    if success then
        C_Timer.After(0.2, function() self:UpdateGUI() end)
    end
end

-- ============================================================================
-- 5. GETTERS Y SETTERS
-- ============================================================================

function GatherTracker:GetCastInterval() return tonumber(self.db.profile.castInterval) or 2 end
function GatherTracker:SetCastInterval(info, newValue)
    self.db.profile.castInterval = newValue
    if self.IS_RUNNING then self:StopTimer() self:StartTimer() end
end

function GatherTracker:GetType1() return self.db.profile.type1 end
function GatherTracker:SetType1(info, newValue) self.db.profile.type1 = newValue end

function GatherTracker:GetType2() return self.db.profile.type2 end
function GatherTracker:SetType2(info, newValue) self.db.profile.type2 = newValue end

function GatherTracker:GetShowFrame() return self.db.profile.showFrame end
function GatherTracker:SetShowFrame(info, val) 
    self.db.profile.showFrame = val 
    self:UpdateGUI() 
end
