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
        
        header2 = { order = 6, type = "header", name = "Visualización (HUD)" },
        hudEnabled = { order = 7, name = "Habilitar HUD", type = "toggle", get = 'GetHudEnabled', set = 'SetHudEnabled', width = "full" },
        hudFade = { order = 8, name = "Tiempo de Borrado (s)", type = "range", min = 10, max = 300, step = 10, get = 'GetHudFade', set = 'SetHudFade' },
    }
}

local defaults = {
    profile  = {
        type1 = "minerals", type2 = "herbs", castInterval = 2,
        showFrame = true,
        pos = { point = "CENTER", x = 0, y = 0 },
        -- Nuevas opciones v1.1.0
        hudEnabled = true,
        hudAlpha = 0.8,
        hudFadeTime = 60, -- segundos
        hudPos = { point = "CENTER", x = 100, y = 0 }
    }
}

-- Lista temporal de nodos vistos
GatherTracker.nodeHistory = {}

-- ============================================================================
-- 3. SISTEMA DE INTERFAZ GRÁFICA (GUI)
-- ============================================================================

function GatherTracker:CreateGUI()
    if self.frame then return end

    local f = CreateFrame("Button", "GatherTrackerFrame", UIParent, "BackdropTemplate")
    f:SetSize(40, 40)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp") -- FIX: Registrar Clic Derecho
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

function GatherTracker:UpdateGUI()
    if not self.frame then return end
    
    if self.db.profile.showFrame then self.frame:Show() else self.frame:Hide() return end

    local currentTexture = GetTrackingTexture()
    if currentTexture then
        self.frame.icon:SetTexture(currentTexture)
        self.frame.icon:SetDesaturated(false)
    else
        self.frame.icon:SetTexture(134400)
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
-- 3.B SISTEMA HUD (v1.1.0)
-- ============================================================================

function GatherTracker:CreateHUD()
    if self.hud then return end

    local f = CreateFrame("Frame", "GatherTrackerHUD", UIParent, "BackdropTemplate")
    f:SetSize(200, 20) -- Altura dinámica luego
    f:SetPoint("CENTER", 100, 0)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    
    -- Fondo semi-transparente para moverlo
    f:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.4) -- Fondo negro transparente
    
    -- Hacerlo movible con Alt
    f:SetScript("OnDragStart", function(self)
        if IsAltKeyDown() then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
        GatherTracker.db.profile.hudPos = { point = point, x = xOfs, y = yOfs }
    end)

    -- Contenedor de texto
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.text:SetPoint("TOPLEFT", 10, -10)
    f.text:SetJustifyH("LEFT")
    f.text:SetText("GatherTracker HUD")

    -- Scripts de interacción y Tooltip
    f:SetScript("OnEnter", function(self) GatherTracker:ShowHUDTooltip(self) end)
    f:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then
            -- Borrar todo
            GatherTracker.nodeHistory = {}
            GatherTracker:UpdateHUD()
            print("|cff00ff00GT:|r Lista borrada.")
        elseif button == "LeftButton" and not IsAltKeyDown() then
             -- Recargar/Actualizar
             GatherTracker:UpdateHUD()
        end
    end)

    self.hud = f
    self:RestoreHudPosition()
    self:UpdateHUDVis()
end

function GatherTracker:ShowHUDTooltip(frame)
    GameTooltip:SetOwner(frame, "ANCHOR_TOP")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("GatherTracker HUD")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffFFFFFFAlt+Arrastrar:|r Mover lista")
    GameTooltip:AddLine("|cffFFFFFFClic Der:|r Borrar lista")
    GameTooltip:AddLine("|cffFFFFFFClic Izq:|r Recargar lista")
    GameTooltip:Show()
end

function GatherTracker:RestoreHudPosition()
    if not self.hud then return end
    local pos = self.db.profile.hudPos
    if pos then
        self.hud:ClearAllPoints()
        self.hud:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    end
end

function GatherTracker:UpdateHUDVis()
    if not self.hud then return end
    if self.db.profile.hudEnabled then
        self.hud:Show()
    else
        self.hud:Hide()
    end
end

function GatherTracker:UpdateHUD()
    if not self.hud or not self.db.profile.hudEnabled then return end
    
    local now = GetTime()
    local textLines = ""
    local count = 0
    local fadeTime = self.db.profile.hudFadeTime or 60

    -- Recorrer historial y limpiar viejos
    for name, data in pairs(self.nodeHistory) do
        local age = now - data.lastSeen
        
        if age > fadeTime then
            self.nodeHistory[name] = nil -- Borrar viejos
        else
            -- Formato: [Mena de Cobre] (15s)
            local color = "|cffffffff" -- Blanco por defecto
            if string.find(name, "Mena") or string.find(name, "Veta") then color = "|cffff9900" -- Naranja
            elseif string.find(name, "Hierba") or string.find(name, "Hoja") or string.find(name, "Flor") then color = "|cff00ff00" -- Verde
            end
            
            textLines = textLines .. color .. name .. "|r |cffaaaaaa(" .. math.floor(age) .. "s)|r\n"
            count = count + 1
        end
    end

    if count == 0 then
        self.hud.text:SetText("|cff888888Esperando datos...|r")
        self.hud:SetHeight(40)
        self.hud:SetBackdropColor(0,0,0,0.1) -- Casi invisible si vacío
    else
        self.hud.text:SetText(textLines)
        self.hud:SetHeight((count * 15) + 20)
        self.hud:SetBackdropColor(0,0,0,0.6) -- Más visible con datos
    end
end

function GatherTracker:HookTooltips()
    -- Hook simple: cuando se muestra el tooltip, leer la línea 1
    GameTooltip:HookScript("OnShow", function(self)
        local owner = self:GetOwner()
        if owner and owner == Minimap then
             -- Solo nos importa si viene del minimapa (puntitos amarillos)
             local line1 = _G["GameTooltipTextLeft1"]
             if line1 then
                local text = line1:GetText()
                if text then
                    GatherTracker:RegisterNode(text)
                end
             end
        end
    end)
    
    -- Fallback para OnTooltipSetUnit si fuera una unidad (menos común en minimapa clásico para recursos, pero útil)
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        -- Logica similar si es necesario
    end)
end

function GatherTracker:RegisterNode(name)
    if not name then return end
    
    -- Filtrar cosas que no sean recursos (opcional, por ahora cojemos todo)
    -- Si es "Mi Personaje" o nombres de jugadores, podríamos ignorar.
    
    local now = GetTime()
    if not self.nodeHistory[name] then
        self.nodeHistory[name] = { count = 1, lastSeen = now }
    else
        self.nodeHistory[name].lastSeen = now
        self.nodeHistory[name].count = self.nodeHistory[name].count + 1
    end
    
    self:UpdateHUD() -- Actualizar al momento
end

-- ============================================================================
-- 4. FUNCIONES PRINCIPALES
-- ============================================================================

-- Variables para rastrear el objetivo del crafteo
GatherTracker.lastSentTarget = nil
GatherTracker.lastSentSpell = nil

function GatherTracker:UNIT_SPELLCAST_SENT(event, unit, target, castGUID, spellID)
    if unit ~= "player" then return end
    self.lastSentTarget = target
    self.lastSentSpell = spellID
end

function GatherTracker:UNIT_SPELLCAST_SUCCEEDED(event, unit, castGUID, spellID)
    if unit ~= "player" then return end
    
    local spellName = GetSpellInfo(spellID)
    if not spellName then return end

    -- Palabras clave para detectar recolección
    local keywords = {"Min", "Herb", "Reco", "Gather", "Abrir", "Open"}
    local isGathering = false
    
    for _, word in ipairs(keywords) do
        if string.find(spellName, word) then
            isGathering = true
            break
        end
    end

    if isGathering then
        -- Usar el target guardado en SENT si coincide con el hechizo actual (aproximado)
        -- O si tenemos un target explícito
        local targetToRemove = self.lastSentTarget
        
        -- Si no hay target en SENT (ej. click derecho sin target), intentamos UnitName("target")
        if not targetToRemove then
            targetToRemove = UnitName("target")
        end

        if targetToRemove then
             self:RemoveSpecificNode(targetToRemove)
        end
        
        -- Limpiar
        self.lastSentTarget = nil
    end
end

function GatherTracker:RemoveSpecificNode(nodeName)
    if not nodeName then return end
    
    -- Buscamos si existe en el historial
    if self.nodeHistory[nodeName] then
        self.nodeHistory[nodeName] = nil
        self:UpdateHUD()
--      print("|cff00ff00GT:|r Nodo eliminado: " .. nodeName) -- Debug opcional
    end
end

function GatherTracker:RemoveMostRecentNode()
    local now = GetTime()
    local bestName = nil
    local minDiff = 10 -- Solo borrar si se vio hace menos de 10 segundos
    
    for name, data in pairs(self.nodeHistory) do
        local diff = now - data.lastSeen
        if diff < minDiff then
            minDiff = diff
            bestName = name
        end
    end
    
    if bestName then
        self.nodeHistory[bestName] = nil
        self:UpdateHUD()
    end
end


function GatherTracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("GatherTrackerCharDB", defaults, true)
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GatherTracker', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('GatherTracker', 'GatherTracker')
    
    self:RegisterChatCommand('gt', 'ChatCommand')
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("UNIT_SPELLCAST_SENT") -- Nuevo evento para capturar target
    
    if not self.db.profile.type1 then self.db.profile.type1 = "minerals" end
    if not self.db.profile.type2 then self.db.profile.type2 = "herbs" end
    if not self.db.profile.castInterval then self.db.profile.castInterval = 2 end
    if self.db.profile.hudEnabled == nil then self.db.profile.hudEnabled = true end

    GatherTracker.IS_RUNNING = false
    self:CreateGUI()
    self:CreateHUD() -- Crear el HUD al inicio
    self:HookTooltips() -- Activar el espía de tooltips

    -- Timer para actualizar el HUD (cada 1s es suficiente para contadores)
    self:ScheduleRepeatingTimer("UpdateHUD", 1)
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

function GatherTracker:TimerFeedback()
    if UnitAffectingCombat("player") or UnitChannelInfo("player") or UnitCastingInfo("player") or UnitIsDeadOrGhost("player") then
        return 
    end

    local currentTrackingIcon = GetTrackingTexture()
    local type1Key = self:GetType1()
    local type2Key = self:GetType2()

    if not type1Key or not trackingMasterList[type1Key] then type1Key = "minerals" end
    if not type2Key or not trackingMasterList[type2Key] then type2Key = "herbs" end

    local targetKey = nil
    if currentTrackingIcon ~= trackingMasterList[type1Key].icon then
        targetKey = type1Key
    else
        targetKey = type2Key
    end

    local spellID = trackingMasterList[targetKey].spellID
    local localizedSpellName = GetSpellInfo(spellID)

    if localizedSpellName then
        CastSpellByName(localizedSpellName)
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

function GatherTracker:GetHudEnabled() return self.db.profile.hudEnabled end
function GatherTracker:SetHudEnabled(info, val)
    self.db.profile.hudEnabled = val
    self:UpdateHUDVis()
end

function GatherTracker:GetHudFade() return self.db.profile.hudFadeTime end
function GatherTracker:SetHudFade(info, val) self.db.profile.hudFadeTime = val end
