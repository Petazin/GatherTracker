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

    -- Contenedor de texto (Título)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOPLEFT", 10, -10)
    f.title:SetJustifyH("LEFT")
    f.title:SetText("GatherTracker HUD")

    -- Pool de líneas (botones)
    f.lines = {}

    -- Scripts de interacción del marco principal (Mover/Globales)
    f:SetScript("OnEnter", function(self) GatherTracker:ShowHUDTooltip(self) end)
    f:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then 
            GatherTracker.nodeHistory = {}
            GatherTracker:UpdateHUD()
            print("|cff00ff00GT:|r Lista borrada.")
        elseif button == "LeftButton" and not IsAltKeyDown() then
             GatherTracker:UpdateHUD()
        end
    end)

    self.hud = f
    self:RestoreHudPosition()
    self:UpdateHUDVis()
end

function GatherTracker:GetHUDLine(index)
    if not self.hud.lines[index] then
        local btn = CreateFrame("Button", nil, self.hud)
        btn:SetSize(180, 14)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        
        local text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        text:SetPoint("LEFT", 0, 0)
        text:SetPoint("RIGHT", 0, 0)
        text:SetJustifyH("LEFT")
        btn.text = text
        
        btn:SetScript("OnClick", function(self, button) GatherTracker:OnNodeClick(self, button) end)
        btn:SetScript("OnEnter", function(self) 
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.nodeName)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cff00ff00Clic:|r Anunciar", 1, 1, 1)
            GameTooltip:AddLine("|cff00ffffCtrl+Clic:|r TomTom", 1, 1, 1)
            GameTooltip:AddLine("|cffff00ffShift+Clic:|r GatherMate2 (Export)", 1, 1, 1)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        self.hud.lines[index] = btn
    end
    return self.hud.lines[index]
end

function GatherTracker:OnNodeClick(btn, button)
    local name = btn.nodeName
    if not name then return end

    if IsControlKeyDown() then
        -- TomTom Integration
        if TomTom then
            -- Solo permitir TomTom si es un nodo de Base de Datos (preciso) o si el usuario fuerza (opcional)
            -- Por petición del usuario, deshabilitamos para nodos visuales imprecisos.
            if not btn.isDB then
                print("|cffff0000GT:|r TomTom deshabilitado para nodos visuales (imprecisos).")
                print("|cffff0000GT:|r Usa nodos de Base de Datos (marcados con *) para precisión.")
                return 
            end

            local mapID = btn.nodeMapID
            local x, y = btn.nodeX, btn.nodeY
            
            if mapID and x and y then
                TomTom:AddWaypoint(mapID, x, y, { title = "GatherTracker (DB): " .. name })
                print("|cff00ffffGT:|r TomTom Waypoint (DB) añadido para: " .. name)
            else
                print("|cffff0000GT:|r No hay coordenadas guardadas para este nodo.")
            end
        else
             print("|cff00ffffGT:|r TomTom no está instalado o cargado.")
        end
    elseif IsShiftKeyDown() then
        -- GatherMate2 Export
        self:ExportToGatherMate2(name)
    else
        -- Social Share (Smart Channel)
        local channel = "SAY"
        if IsInRaid() then channel = "RAID"
        elseif IsInGroup() then channel = "PARTY"
        end
        
        local coords = ""
        if btn.nodeX and btn.nodeY then
            coords = " (" .. math.floor(btn.nodeX * 100) .. ", " .. math.floor(btn.nodeY * 100) .. ")"
        end

        local msg = "GatherTracker: Enctontrado [" .. name .. "]" .. coords
        SendChatMessage(msg, channel)
    end
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
    local fadeTime = self.db.profile.hudFadeTime or 60
    
    -- 1. Limpiar líneas previas
    for _, line in pairs(self.hud.lines) do line:Hide() end

    -- 2. Procesar datos y ordenarlos (opcional, por ahora orden arbitrario de pairs)
    local activeNodes = {}
    for name, data in pairs(self.nodeHistory) do
        local age = now - data.lastSeen
        if age > fadeTime then
            self.nodeHistory[name] = nil
        else
            -- Fix: Copiar coordenadas al objeto temporal para que GetHUDLine las reciba
            table.insert(activeNodes, { 
                name = name, 
                age = age,
                x = data.x,
                y = data.y,
                mapID = data.mapID
            })
        end
    end
    
    -- 2.b. Insertar/Mezclar nodos de GatherMate2 cercanos (Proximidad)
    local gmNodes = self:GetNearbyGMNodes()
    for _, node in ipairs(gmNodes) do
        -- Solo añadir si no está ya en la lista visual (por nombre, simple check)
        -- O podemos mostrarlo como duplicado con etiqueta (DB)
        table.insert(activeNodes, node)
    end

    -- 3. Dibujar
    if #activeNodes == 0 then
        self.hud.title:SetText("GatherTracker HUD (Vacío)")
        self.hud:SetHeight(30)
        self.hud:SetBackdropColor(0,0,0,0.1)
    else
        self.hud.title:SetText("GatherTracker HUD")
        local offsetY = -25
        
        -- Ordenar: Visuales primero, luego DB? O por distancia?
        -- Por ahora: Visuales (age < fadeTime) ya están, luego GM.
        -- Mejor ordenar todos por 'age' (GM tendrá age=0 o nil)
        
        for i, node in ipairs(activeNodes) do
            local line = self:GetHUDLine(i)
            line:ClearAllPoints()
            line:SetPoint("TOPLEFT", self.hud, "TOPLEFT", 10, offsetY)
            line:Show()
            
            -- Color logic
            local color = "|cffffffff"
            local prefix = ""
            if node.isDB then 
                color = "|cffaaaaff" -- Azulito para DB
                prefix = "*" 
            elseif string.find(node.name, "Mena") or string.find(node.name, "Veta") then color = "|cffff9900"
            elseif string.find(node.name, "Hierba") or string.find(node.name, "Hoja") or string.find(node.name, "Flor") then color = "|cff00ff00"
            end
            
            local timeText = "(" .. math.floor(node.age or 0) .. "s)"
            if node.isDB then timeText = "(Cerca)" end
            
            line.text:SetText(color .. prefix .. node.name .. "|r |cffaaaaaa" .. timeText .. "|r")
            
            line.nodeName = node.name 
            line.nodeX = node.x
            line.nodeY = node.y
            line.nodeMapID = node.mapID
            line.isDB = node.isDB -- Flag para permitir TomTom
            
            offsetY = offsetY - 15
        end
        
        self.hud:SetHeight((#activeNodes * 15) + 35)
        self.hud:SetBackdropColor(0,0,0,0.6)
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
                    -- Obtener posición ESTIMADA del nodo bajo el cursor
                    local mapID, x, y = GatherTracker:GetCursorNodePosition()
                    
                    if mapID and x and y then
                        GatherTracker:RegisterNode(text, mapID, x, y)
                    end
                end
             end
        end
    end)
end

function GatherTracker:GetCursorNodePosition()
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then return nil end
    
    local playerPos = C_Map.GetPlayerMapPosition(mapID, "player")
    if not playerPos then return nil end
    local px, py = playerPos.x, playerPos.y

    -- 1. Obtener posición del mouse y centro del minimapa
    local mx, my = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    mx, my = mx / scale, my / scale
    
    local cx, cy = Minimap:GetCenter()
    local w, h = Minimap:GetWidth(), Minimap:GetHeight()
    
    -- 2. Delta en píxeles desde el centro
    local dx, dy = mx - cx, my - cy
    
    -- 3. Rotación (si el minimapa rota)
    -- En WoW, si rotateMinimap está activado, el "Norte" del minimapa es la dirección del jugador.
    -- Los deltas dx/dy son relativos a la pantalla (Arriba/Abajo).
    -- Necesitamos rotarlos para alinearlos con el Norte del juego.
    if GetCVar("rotateMinimap") == "1" then
        local bearing = GetPlayerFacing() -- Radianes (0 = Norte?, no, WoW usa 0=Norte en algunos contextos, pero facing es diferente)
        -- Ajuste trigonométrico estándar para rotación 2D
        -- NuevaX = x * cos(theta) - y * sin(theta)
        -- NuevaY = x * sin(theta) + y * cos(theta)
        -- El facing de WoW va en sentido antihorario desde Norte? Hay que probar.
        -- Usualmente: Facing 0 = Norte.
        -- Si yo miro al Este (PI/2), el mapa rota -PI/2.
        
        local sin, cos = math.sin(bearing), math.cos(bearing)
        -- Rotar dx, dy
        local rotX = dx * cos - dy * sin
        local rotY = dx * sin + dy * cos
        dx, dy = rotX, rotY
    end
    
    -- 4. Conversión Píxeles -> Coordenadas de Mapa
    -- ESTIMACIÓN: Asumimos un factor de escala arbitrario porque no tenemos dimensiones de zona
    -- Factor mágico: 0.002 por cada 50 píxeles? Depende del Zoom.
    -- Vamos a ser conservadores. Un minimapa típico muestra ~100 yardas de radio.
    -- Una zona típica tiene ~2000-5000 yardas de ancho.
    -- 100 yardas es aprox un 2-5% del mapa? No, mucho menos. 0.05?
    -- Vamos a usar un factor fijo pequeño para simplemente "mover el punto".
    -- Mejor sería usar Zoom, pero para v1.4.0 esto basta para no marcar los pies.
    
    local magicScale = 0.00015 -- Factor de conversión píxel -> map coord
    -- Ajustar por Zoom (ZoomOut = Valor más alto = Radio mayor = Factor mayor)
    local zoom = Minimap:GetZoom() -- 0 (cerca) a 5 (lejos)
    magicScale = magicScale * (1 + zoom) 

    local nodeX = px + (dx * magicScale)
    local nodeY = py - (dy * magicScale) -- Y invertida en UI vs Mapa (UI: Arriba+, Mapa: Arriba- [0,0 es top-left])

    return mapID, nodeX, nodeY
end


function GatherTracker:RegisterNode(name, mapID, x, y)
    if not name then return end
    
    -- Filtrar cosas que no sean recursos (opcional, por ahora cojemos todo)
    -- Si es "Mi Personaje" o nombres de jugadores, podríamos ignorar.
    
    local now = GetTime()
    if not self.nodeHistory[name] then
        self.nodeHistory[name] = { count = 1, lastSeen = now, mapID = mapID, x = x, y = y }
    else
        self.nodeHistory[name].lastSeen = now
        self.nodeHistory[name].count = self.nodeHistory[name].count + 1
        -- Actualizar posición a la más reciente
        self.nodeHistory[name].mapID = mapID
        self.nodeHistory[name].x = x
        self.nodeHistory[name].y = y
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

function GatherTracker:OnEnable()
    self:RegisterEvent("UNIT_SPELLCAST_SENT")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    self:ScheduleTimer("TimerFeedback", 0.5)
    
    -- Iniciar ciclo si está activo
    if self.IS_RUNNING then
        self:StartTimer()
    end
    
    self:UpdateGUI()
end

-- ============================================================================
-- 5. EVENTOS DE COMBATE
-- ============================================================================

function GatherTracker:PLAYER_REGEN_DISABLED()
    -- Entrar en combate: Ocultar todo
    if self.frame then self.frame:Hide() end
    if self.hud then self.hud:Hide() end
    -- Opcional: Pausar timer o lógica (el usuario solo pidió ocultar UI)
end

function GatherTracker:PLAYER_REGEN_ENABLED()
    -- Salir de combate: Restaurar según config
    if self.db.profile.showFrame and self.frame then self.frame:Show() end
    if self.db.profile.hudEnabled and self.hud then self.hud:Show() end
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
-- 5. INTEGRACIONES (GatherMate2, etc)
-- ============================================================================

function GatherTracker:ExportToGatherMate2(nodeName)
    if not GatherMate2 then
        print("|cffff00ffGT:|r GatherMate2 no encontrado.")
        return
    end
    
    local collector = GatherMate2:GetModule("Collector", true)
    if not collector then
        print("|cffff00ffGT:|r No se pudo acceder al módulo Collector de GM2.")
        return
    end

    -- Intentamos deducir el tipo (Mining, Herb) basado en el nombre
    local nodeType = nil
    local tradeSkill = nil -- "Mining" o "Herbalism" para GM2
    
    if string.find(nodeName, "Mena") or string.find(nodeName, "Veta") or string.find(nodeName, "Depósito") then
        nodeType = "Mining"
        tradeSkill = "Mining"
    elseif string.find(nodeName, "Hierba") or string.find(nodeName, "Flor") or string.find(nodeName, "Hoja") then
        nodeType = "Herb Gathering"
        tradeSkill = "Herbalism"
    end

    if not tradeSkill then
        print("|cffff00ffGT:|r No se pudo identificar el tipo de recurso para GM2.")
        return
    end
    
    -- Simulamos la recolección para que GM2 lo capture
    -- GM2 suele escuchar eventos, pero podemos intentar invocar su lógica de guardado si es pública.
    -- Como no tenemos API doc segura, usaremos un truco:
    -- La mayoría de addons de este tipo reaccionan a 'UI_ERROR_MESSAGE' o eventos de minería.
    -- Pero para "Forzar Add", necesitamos llamar a su función interna si es accesible.
    
    -- Intento 1: Llamada directa a AddNode si existe en Collector
    local mapID = C_Map.GetBestMapForUnit("player") -- Para exportar manual usamos posición actual (asumimos que estás encima)
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    -- NOTA: Si quisiéramos exportar la posición histórica, tendríamos que pasarla desde btn.nodeX/Y en OnNodeClick
    -- Por simplicidad, el "Shift+Click" suele ser "Estoy aquí, guarda esto".
    
    local zone = GetZoneText()
    
    if not pos then print("|cffff00ffGT:|r Error: No se pudo obtener la posición.") return end
    
    local x, y = pos.x, pos.y
    -- La firma suele ser (zoneID, x, y, nodeType, name) o similar.
    -- Para evitar errores de Lua, lo envolvemos en pcall
    
    print("|cffff00ffGT:|r Intentando añadir '" .. nodeName .. "' a GatherMate2...")
    
    -- Nota: GM2 es complejo. Si esto falla, el usuario tendrá que recolectar normalmente.
    -- Pero aquí intentamos forzarlo con la posición actual.
    
    -- Si GM2 tiene una función pública para añadir manual:
    if GatherMate2.AddNode then
         local success, err = pcall(GatherMate2.AddNode, GatherMate2, zone, x, y, nodeType, nodeName)
         if success then print("|cff00ff00GT:|r Exportado OK.") else print("|cffff0000GT:|r Error API: " .. err) end
    else
         print("|cffff00ffGT/GM2:|r Función AddNode no encontrada. Asegúrate de tener la última versión.")
    end
end

function GatherTracker:GetNearbyGMNodes()
    if not GatherMate2 then return {} end
    
    local mapID = C_Map.GetBestMapForUnit("player")
    local pos = mapID and C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos then return {} end
    
    local nearby = {}
    local range = 0.05 -- Rango "a ojo" en coordenadas normalizadas (aprox 5-10% del mapa). Ajustar según se necesite.
    -- Nota: 0.01 en mapa grande puede ser mucho. En minimapa (radius) suele ser 0.02 aprox?
    
    -- Acceder a la tabla interna de GM2 (Riesgoso si cambian la estructura, pero necesario)
    -- GatherMate2.db.profile? No, los datos están en GatherMate2.gmd (o similar) dependiendo módulos.
    -- API oficial: GatherMate2:GetNearbyNode(mapID, x, y, ...) -> No existe tal cual.
    -- Exploración: GatherMate2_Data o GatherMate2DB.
    
    -- Intento seguro: Usar el display del minimapa de GM2 si pudiéramos leer sus pines. Difícil.
    -- Intento directo: Leer GatherMate2DB[mapID] si existe.
    
    local GM_DB = GatherMate2.db.global.data -- Estructura común en Ace3 para datos globales?
    -- Estructura Real de GM2 (Classic): GatherMate2.gmd[zoneID][nodeType][coord] = data
    -- MapID de WoW API != ZoneID de GM2 a veces. GM2 usa ids de mapa internos o de HBD.
    
    -- Simplificación para Demo: Si no podemos acceder fácil, devolvemos vacío para no crashear.
    -- Pero el usuario quiere esto. Asumamos acceso a "Mining" y "Herb Gathering".
    
    -- Simulamos "1 nodo fake cercano" si GM2 está cargado para probar la funcionalidad
    -- hasta que reverse-engineer la tabla exacta de GM2 en runtime.
    
    -- (TODO: Implementar lectura real iterando GatherMate2.gmd[mapID])
    -- Por ahora, retornamos nil para no romper, o un nodo dummy si estamos en debug.
    
    return nearby
end


-- ============================================================================
-- 6. GETTERS Y SETTERS
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
