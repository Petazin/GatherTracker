GatherTracker = LibStub("AceAddon-3.0"):NewAddon("GatherTracker", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

-- ============================================================================
-- 1. TABLAS DE DATOS
-- ============================================================================
-- ============================================================================
-- 1. TABLAS DE DATOS
-- ============================================================================
-- Se ha eliminado trackingMasterList y los valores estáticos por clase.
-- Ahora se detectan dinámicamente en tiempo de ejecución.

-- Almacenará las opciones detectadas: [NombreLocalizado] = NombreLocalizado
local availableTrackingTypes = {}

-- Diccionario de Nodos (Simplificado)


-- ID UNIVERSAL LIST (Para Loot Tracking Agnóstico al Idioma)
local validItemIDs = {
    -- Classic Ores
    [2770] = true, -- Copper Ore
    [2771] = true, -- Tin Ore
    [2775] = true, -- Silver Ore
    [2772] = true, -- Iron Ore
    [2776] = true, -- Gold Ore
    [3858] = true, -- Mithril Ore
    [7911] = true, -- Truesilver Ore
    [10620] = true, -- Thorium Ore
    [11370] = true, -- Dark Iron Ore
    [12363] = true, -- Arcane Crystal
    
    -- TBC Ores
    [23424] = true, -- Fel Iron Ore
    [23425] = true, -- Adamantite Ore
    [23426] = true, -- Khorium Ore
    [23427] = true, -- Eternium Ore
    
    -- Stones
    [2835] = true, -- Rough Stone
    [2836] = true, -- Coarse Stone
    [2838] = true, -- Heavy Stone
    [7912] = true, -- Solid Stone
    [12365] = true, -- Dense Stone
    
    -- Gems (Classic)
    [774] = true, [1206] = true, [1210] = true, [1225] = true, [1705] = true, 
    [5489] = true, [3864] = true, [7909] = true, [12799] = true, [7910] = true, 
    [7907] = true, [12800] = true, 
    -- Gems (TBC Uncut)
    [23077] = true, [23076] = true, [23073] = true, [23071] = true,
    [23072] = true, [23074] = true, [25867] = true, [25868] = true,

    -- Classic Herbs
    [2447] = true, [765] = true, [2449] = true, [785] = true, [2450] = true,
    [3820] = true, [2453] = true, [3355] = true, [3356] = true, [3357] = true,
    [3358] = true, [3818] = true, [3821] = true, [3369] = true, [3819] = true,
    [4625] = true, [8831] = true, [8836] = true, [8838] = true, [8839] = true,
    [8845] = true, [8846] = true, [13463] = true, [13464] = true, [13465] = true,
    [13466] = true, [13467] = true, [13468] = true,

    -- TBC Herbs
    [22785] = true, [22786] = true, [22787] = true, [22789] = true, [22790] = true,
    [22791] = true, [22792] = true, [22793] = true, [22794] = true
}

-- ============================================================================
-- 2. CONFIGURACIÓN DEL MENÚ
-- ============================================================================
local options = {
    name = 'GatherTracker', handler = GatherTracker, type = 'group',
    args = {
        header = { order = 1, type = "header", name = "Configuración de Rastreo" },
        type1 = { order = 2, name = "Rastreo Primario", type = "select", values = function() return availableTrackingTypes end, get = 'GetType1', set = 'SetType1' },
        type2 = { order = 3, name = "Rastreo Secundario", type = "select", values = function() return availableTrackingTypes end, get = 'GetType2', set = 'SetType2' },
        castInterval = { order = 4, name = "Intervalo (segundos)", type = "range", min = 2, max = 60, step = 1, get = 'GetCastInterval', set = 'SetCastInterval', width = "full" },
        showFrame = { order = 5, name = "Mostrar Botón Flotante", type = "toggle", get = 'GetShowFrame', set = 'SetShowFrame', width = "full" },
        muteSound = { order = 6, name = "Silenciar Sonidos", desc = "Desactiva el sonido al cambiar de rastreo.", type = "toggle", get = 'GetMuteSound', set = 'SetMuteSound' },
        
        headerInfo = { order = 10, type = "header", name = "Información del Tooltip" },
        showDurability = { order = 11, name = "Mostrar Durabilidad", type = "toggle", get = 'GetShowDurability', set = 'SetShowDurability' },
        showSkillLevel = { order = 12, name = "Nivel de Profesión", type = "toggle", get = 'GetShowSkillLevel', set = 'SetShowSkillLevel' },

        headerAuto = { order = 20, type = "header", name = "Automatización" },
        autoSell = { order = 21, name = "Auto-Vender Grises", desc = "Vende automáticamente objetos de calidad gris al visitar un comerciante.", type = "toggle", get = 'GetAutoSell', set = 'SetAutoSell', width = "full" },
        combatHide = { order = 22, name = "Ocultar en Combate", desc = "Oculta el botón y pausa el rastreo al entrar en combate.", type = "toggle", get = 'GetCombatHide', set = 'SetCombatHide' },
        combatHideMounted = { order = 23, name = "Permitir si Montado", desc = "Si estás montado, sigue rastreando incluso en combate.", type = "toggle", get = 'GetCombatHideMounted', set = 'SetCombatHideMounted', disabled = function() return not GatherTracker.db.profile.combatHide end },
        resumeAfterCombat = { order = 24, name = "Autoreanudar tras Combate", desc = "Si está activado, el rastreo se volverá a iniciar automáticamente al salir de combate.", type = "toggle", get = 'GetResumeAfterCombat', set = 'SetResumeAfterCombat', width = "full" },
        
        headerPause = { order = 30, type = "header", name = "Pausar Automáticamente" },
        pauseInStealth = { order = 31, name = "En Sigilo", type = "toggle", get = 'GetPauseInStealth', set = 'SetPauseInStealth' },
        pauseInResting = { order = 32, name = "En Zona de Descanso", type = "toggle", get = 'GetPauseInResting', set = 'SetPauseInResting' },
        pauseTargetEnemy = { order = 33, name = "Al seleccionar Enemigo", type = "toggle", get = 'GetPauseTargetEnemy', set = 'SetPauseTargetEnemy' },
        pauseInInstance = { order = 34, name = "En Mazmorra/Raid", type = "toggle", get = 'GetPauseInInstance', set = 'SetPauseInInstance' },

    }
}

local defaults = {
    profile  = {
        type1 = "", type2 = "", castInterval = 2,
        showFrame = true,
        autoSell = false,
        combatHide = true,
        resumeAfterCombat = false, 
        pos = { point = "CENTER", x = 0, y = 0 },
        -- v1.6.0
        muteSound = false,
        showDurability = false,
        showSkillLevel = true,
        pauseInStealth = false,
        pauseInResting = false,
        pauseTargetEnemy = false,
        pauseInInstance = false,
        combatHideMounted = false 
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
    f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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
    
    -- Sección de Historial
    if #GatherTracker.nodeHistory > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Historial Reciente:", 0, 1, 1)
        local now = GetTime()
        for i, node in ipairs(GatherTracker.nodeHistory) do
            local diff = now - node.time
            if diff < 120 then -- Mostrar solo últimos 2 min
                local timeStr = ""
                if diff < 60 then timeStr = math.floor(diff).."s"
                else timeStr = math.floor(diff/60).."m" end
                GameTooltip:AddDoubleLine(node.name, "hace " .. timeStr, 1, 1, 1, 0.7, 0.7, 0.7)
            end
        end
    end
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
    
    -- Fix: Respetar ocultamiento en combate (usando flag propio y API)
    if self.db.profile.combatHide and (self.inCombat or InCombatLockdown()) then
        self.frame:Hide()
        return
    end

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
    self.db = LibStub("AceDB-3.0"):New("GatherTrackerDB", defaults, true)
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GatherTracker', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('GatherTracker', 'GatherTracker')
    
    self:RegisterChatCommand('gt', 'ChatCommand')
    self:RegisterChatCommand('gtr', 'ChatCommand')
    self:RegisterChatCommand('gtrack', 'ChatCommand')
    
    -- Eventos
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatEnter")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatLeave")
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    -- self:RegisterEvent("SKILL_LINES_CHANGED", "CheckProfessions") -- Obsolte, now fully dynamic on tracking update
    
    if not self.db.profile.castInterval then self.db.profile.castInterval = 2 end
    
    self:ScanTrackingSpells() -- Escaneo inicial
    
    -- Establecer valores por defecto inteligentes si están vacíos
    if (not self.db.profile.type1 or self.db.profile.type1 == "") and next(availableTrackingTypes) then
        for name, _ in pairs(availableTrackingTypes) do
             if not self.db.profile.type1 or self.db.profile.type1 == "" then
                self.db.profile.type1 = name
             elseif not self.db.profile.type2 or self.db.profile.type2 == "" then
                self.db.profile.type2 = name
                break
             end
        end
    end

    GatherTracker.IS_RUNNING = false
    self:CreateGUI()
    self.lootSession = {} -- Tabla de sesión: [itemID] = { count, name, link }
    
    -- Inicializar estado de combate
    self.inCombat = InCombatLockdown()
    
    -- Evento de Loot
    self:RegisterEvent("CHAT_MSG_LOOT", "OnLootMsg")
    
    local version = C_AddOns and C_AddOns.GetAddOnMetadata("GatherTracker", "Version") or GetAddOnMetadata("GatherTracker", "Version")
    print("|cff00ff00GatherTracker:|r v" .. (version or "Unknown") .. " cargado (TBC).")
end

function GatherTracker:OnLootMsg(event, msg)
    -- Patrones simples para detectar loot (Español e Inglés)
    -- ES: "Recibes botín: [Mena de hierro]x2." o "Recibes botín: [Mena de hierro]."
    -- EN: "You receive loot: [Iron Ore]x2."
    
    local link = string.match(msg, "|Hitem:.-|h")
    if not link then return end
    
    -- Verificar si es un item que nos interesa (está en validNodes o es un Trade Good relevante)
    local itemID = GetItemInfoInstant(link)
    if not itemID then return end

    -- FIX UNIVERSAL: Comprobar ID en lugar de nombre para soporte multi-idioma
    if not validItemIDs[itemID] then return end 
    
    local name = GetItemInfo(link) -- Nombre localized para mostrar en tooltip

    -- Extraer cantidad
    local count = 1
    local quantityMatch = string.match(msg, "x(%d+)%.")
    if quantityMatch then count = tonumber(quantityMatch) end
    

    
    -- Guardar en sesión
    if not self.lootSession[itemID] then
        self.lootSession[itemID] = { count = 0, name = name, link = link }
    end
    self.lootSession[itemID].count = self.lootSession[itemID].count + count
end

function GatherTracker:GetAuctionPrice(link)
    -- Soporte para addons de subasta populares (Auctionator, TSM, Aux)
    -- Auctionator
    if Atr_GetAuctionBuyout then 
        return Atr_GetAuctionBuyout(link) 
    end
    -- TSM (API compleja, intento simple)
    if TSM_API and TSM_API.GetCustomPriceValue then
        -- TSM requiere formato "i:ID"
        local itemID = GetItemInfoInstant(link)
        if itemID then
             local price = TSM_API.GetCustomPriceValue("DBMarket", "i:" .. itemID)
             if price then return price end
        end
    end
    -- Fallback: Aux (Classic)
    if Aux and Aux.GetMinBuyout then
         return Aux.GetMinBuyout(link)
    end
    
    return 0
end

-- Funciones eliminadas: ScanTooltip, AnnounceLastNode (ya no aplica nodeHistory)
-- Reemplazamos UpdateTooltip para mostrar tabla de loot
-- Helper para durabilidad
function GatherTracker:GetAverageDurability()
    local cur, max = 0, 0
    for i = 1, 18 do
        local c, m = GetInventoryItemDurability(i)
        if c and m then
            cur = cur + c
            max = max + m
        end
    end
    if max == 0 then return 100 end
    return (cur / max) * 100
end

-- Helper para skill level (Hybrid: Modern APIs + Legacy Scan)
function GatherTracker:GetAllGatheringSkills()
    local skills = {}
    local relevantNames = { 
        ["Mining"]=true, ["Minería"]=true, 
        ["Herbalism"]=true, ["Herboristería"]=true, 
        ["Skinning"]=true, ["Desuello"]=true, 
        ["Fishing"]=true, ["Pesca"]=true 
    }
    
    -- Method 1: GetProfessions (Modern/WotLK+)
    if GetProfessions then
        local profs = {GetProfessions()}
        local relevantIDs = { [182]=true, [186]=true, [393]=true, [356]=true }
        
        for _, index in pairs(profs) do
            if index then
                local name, _, rank, maxRank, _, _, skillLineID = GetProfessionInfo(index)
                local isRelevant = false
                
                if skillLineID and relevantIDs[skillLineID] then isRelevant = true end
                if not isRelevant and name and relevantNames[name] then isRelevant = true end
                
                if isRelevant then
                    table.insert(skills, { name = name, rank = rank, max = maxRank })
                end
            end
        end
    end

    -- Method 2: Legacy Scan (Classic/TBC fallback)
    -- Si el método 1 no devolvió nada, escaneamos el libro de habilidades manualmente
    if #skills == 0 then
        local numSkills = GetNumSkillLines()
        for i = 1, numSkills do
            local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
            if not isHeader and skillName and relevantNames[skillName] then
                 table.insert(skills, { name = skillName, rank = skillRank, max = skillMaxRank })
            end
        end
    end
    
    return skills
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
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine("Intervalo:", "|cffFFFF00" .. GatherTracker:GetCastInterval() .. " seg|r")

    -- V1.6.0 Info Extra
    if self.db.profile.showDurability then
        local dur = self:GetAverageDurability()
        local r, g, b = 0, 1, 0 -- Verde
        if dur < 30 then r, g, b = 1, 0, 0 -- Rojo
        elseif dur < 70 then r, g, b = 1, 1, 0 end -- Amarillo
        GameTooltip:AddDoubleLine("Durabilidad:", string.format("|cff%02x%02x%02x%d%%|r", r*255, g*255, b*255, dur))
    end
    
    -- Detectar skills una sola vez
    local currentSkills = self:GetAllGatheringSkills()
    
    if self.db.profile.showSkillLevel then
        for _, skill in ipairs(currentSkills) do
            GameTooltip:AddDoubleLine(skill.name..":", skill.rank.."/"..skill.max, 1, 1, 1, 0.7, 0.7, 0.7)
        end
    end

    GameTooltip:AddLine(" ")
    
    -- Sección de Loot (Smart Hide)
    local hasLoot = next(GatherTracker.lootSession) ~= nil
    local hasGatheringProfs = #currentSkills > 0
    
    -- Mostrar si tiene loot O si tiene profesiones (para mostrar 'Sin datos')
    if hasLoot or hasGatheringProfs then
        GameTooltip:AddLine("Sesión de Farm:", 0, 1, 1)
        
        -- Cabecera con pipe para separar visualmente
        GameTooltip:AddDoubleLine("Item (Cant)", "Venta  |  AH", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
        
        local sUnits, sVendor, sAH = 0, 0, 0
        local bUnits, bVendor, bAH = 0, 0, 0
        local anyItem = false
        
        for id, data in pairs(GatherTracker.lootSession) do
            anyItem = true
            
            -- Datos Session
            local vendorPrice = select(11, GetItemInfo(data.link)) or 0
            local ahPrice = GatherTracker:GetAuctionPrice(data.link) or 0
            
            sUnits = sUnits + data.count
            sVendor = sVendor + (vendorPrice * data.count)
            if ahPrice > 0 then sAH = sAH + (ahPrice * data.count) end
    
            -- Datos Bolsa (De este item)
            local bagCount = GetItemCount(id)
            bUnits = bUnits + bagCount
            bVendor = bVendor + (vendorPrice * bagCount)
            if ahPrice > 0 then bAH = bAH + (ahPrice * bagCount) end
            
            local totalVendor = GetCoinTextureString(vendorPrice * data.count)
            local totalAH = (ahPrice > 0) and GetCoinTextureString(ahPrice * data.count) or "|cff808080N/A|r"
            
            -- Alineación " | "
            GameTooltip:AddDoubleLine(data.name .. " x" .. data.count, totalVendor .. " | " .. totalAH, 1, 1, 1, 1, 1, 1)
        end
        
        if not anyItem then
            GameTooltip:AddLine("Sin datos aún...", 0.5, 0.5, 0.5)
        else
            GameTooltip:AddLine(" ")
            -- Totales
            local sVStr = GetCoinTextureString(sVendor)
            local sAHStr = (sAH > 0) and GetCoinTextureString(sAH) or "N/A"
            GameTooltip:AddDoubleLine("|cff00ff00TOTAL SESIÓN ("..sUnits.."u)|r", sVStr .. " | " .. sAHStr)
            
            local bVStr = GetCoinTextureString(bVendor)
            local bAHStr = (bAH > 0) and GetCoinTextureString(bAH) or "N/A"
            GameTooltip:AddDoubleLine("|cff00ffffTOTAL BOLSA ("..bUnits.."u)|r", bVStr .. " | " .. bAHStr)
        end
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffFFFFFFClic Izq:|r Activar/Pausar")
    GameTooltip:AddLine("|cffFFFFFFRueda:|r Ajustar Tiempo")
    GameTooltip:AddLine("|cffFFFFFFClic Der:|r Opciones")
    GameTooltip:Show()
end

function GatherTracker:MINIMAP_UPDATE_TRACKING()
    self:ScanTrackingSpells() -- Actualizar lista de posibles
    self:UpdateGUI()
end

function GatherTracker:OnCombatEnter()
    self.inCombat = true
    if self.db.profile.combatHide then
        -- V1.6.0: Permitir si montado
        if self.db.profile.combatHideMounted and IsMounted() then
             return
        end
        if self.frame then self.frame:Hide() end
        self:StopTimer()
    end
end

function GatherTracker:OnCombatLeave()
    self.inCombat = false
    if self.db.profile.showFrame then
        if self.frame then self.frame:Show() end
    end
    if self.db.profile.resumeAfterCombat then
        self:StartTimer()
    end
end

function GatherTracker:OnMerchantShow()
    if not self.db.profile.autoSell then return end
    
    local count = 0
    local money = 0
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot) -- API moderna/TBC
            if info and info.hyperlink then
                local _, _, quality, _, _, _, _, _, _, _, sellPrice = GetItemInfo(info.hyperlink)
                if quality == 0 and sellPrice and sellPrice > 0 then
                    C_Container.UseContainerItem(bag, slot)
                    count = count + 1
                    money = money + sellPrice
                end
            end
        end
    end
    
    if count > 0 then
        print("|cff00ff00GatherTracker:|r Vendidos " .. count .. " objetos grises por " .. GetCoinTextureString(money))
    end
end


function GatherTracker:ScanTrackingSpells()
    -- Limpiar tabla, manteniendo referencia si es posible, o reasignando
    for k in pairs(availableTrackingTypes) do availableTrackingTypes[k] = nil end
    
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name
        if type(info) == "table" then
            name = info.name
        else
            name = info
        end
        
        -- Añadir a la lista de opciones válidas (Key = Name, Label = Name)
        -- Usamos el nombre como Key para persistencia más amigable que IDs dinámicos
        if name then
            availableTrackingTypes[name] = name
        end
    end
    
    -- Notificar a AceConfig que las opciones han cambiado (si hiciera falta refresh manual)
    -- LibStub("AceConfigRegistry-3.0"):NotifyChange("GatherTracker")
end

-- CheckProfessions y CheckProfessionsDelayed ya no son necesarios con el sistema dinámico puro.
-- Se eliminan para evitar sobrescribir configuraciones de usuario.

-- Getters y Setters adicionales
function GatherTracker:GetAutoSell() return self.db.profile.autoSell end
function GatherTracker:SetAutoSell(info, val) self.db.profile.autoSell = val end

function GatherTracker:GetCombatHide() return self.db.profile.combatHide end
function GatherTracker:SetCombatHide(info, val) self.db.profile.combatHide = val end

function GatherTracker:GetCombatHideMounted() return self.db.profile.combatHideMounted end
function GatherTracker:SetCombatHideMounted(info, val) self.db.profile.combatHideMounted = val end

function GatherTracker:GetResumeAfterCombat() return self.db.profile.resumeAfterCombat end
function GatherTracker:SetResumeAfterCombat(info, val) self.db.profile.resumeAfterCombat = val end

-- v1.6.0 Getters/Setters
function GatherTracker:GetMuteSound() return self.db.profile.muteSound end
function GatherTracker:SetMuteSound(info, val) self.db.profile.muteSound = val end

function GatherTracker:GetShowDurability() return self.db.profile.showDurability end
function GatherTracker:SetShowDurability(info, val) self.db.profile.showDurability = val end

function GatherTracker:GetShowSkillLevel() return self.db.profile.showSkillLevel end
function GatherTracker:SetShowSkillLevel(info, val) self.db.profile.showSkillLevel = val end

function GatherTracker:GetPauseInStealth() return self.db.profile.pauseInStealth end
function GatherTracker:SetPauseInStealth(info, val) self.db.profile.pauseInStealth = val end

function GatherTracker:GetPauseInResting() return self.db.profile.pauseInResting end
function GatherTracker:SetPauseInResting(info, val) self.db.profile.pauseInResting = val end

function GatherTracker:GetPauseTargetEnemy() return self.db.profile.pauseTargetEnemy end
function GatherTracker:SetPauseTargetEnemy(info, val) self.db.profile.pauseTargetEnemy = val end

function GatherTracker:GetPauseInInstance() return self.db.profile.pauseInInstance end
function GatherTracker:SetPauseInInstance(info, val) self.db.profile.pauseInInstance = val end


function GatherTracker:ChatCommand(input)
    local command = input and input:trim()
    if not command or command == "" then
        self:ToggleTracking()
    elseif command == "opt" or command == "options" then
        LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
    else
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
    if self.trackingTimer then self:CancelTimer(self.trackingTimer) end
    print('|cff00ff00GatherTracker:|r Iniciado. Intervalo: ' .. self:GetCastInterval() .. 's');
    self.trackingTimer = self:ScheduleRepeatingTimer('TimerFeedback', self:GetCastInterval())
    self.IS_RUNNING = true
    self:UpdateGUI()
end

function GatherTracker:StopTimer()
    print('|cff00ff00GatherTracker:|r Detenido.');
    self:CancelTimer(self.trackingTimer);
    self.IS_RUNNING = false
    self:UpdateGUI()
end

-- Nueva función para activar por NOMBRE exacto
function GatherTracker:SetTrackingByName(targetName)
    if not targetName then return false end
    
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name
        if type(info) == "table" then name = info.name else name = info end
        
        if name == targetName then
            -- V1.6.0 Fix: Silenciar error "Facultad no lista" si hay GCD
            UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
            
            -- V1.6.0 Fix: Silenciar sonido del sistema si está configurado
            local shouldMute = self.db.profile.muteSound
            local oldSFX
            if shouldMute then
                oldSFX = GetCVar("Sound_EnableSFX")
                SetCVar("Sound_EnableSFX", "0")
            end

            C_Minimap.SetTracking(i, true)

            if shouldMute and oldSFX then
                SetCVar("Sound_EnableSFX", oldSFX)
            end

            UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
            return true
        end
    end
    return false
end

-- Verificar si está activo por NOMBRE
function GatherTracker:IsTrackingActive(targetName)
    if not targetName then return false end
    
    local count = C_Minimap.GetNumTrackingTypes()
    for i = 1, count do
        local info = C_Minimap.GetTrackingInfo(i)
        local name, active
        if type(info) == "table" then
            name = info.name
            active = info.active
        else
             name, _, active = info, select(3, C_Minimap.GetTrackingInfo(i))
        end

        if name == targetName and active then
            return true
        end
    end
    return false
end

-- Helper para verificar ataque
local function IsEnemyTarget()
    return UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
end

function GatherTracker:TimerFeedback()
    -- Checks Base: En combate siempre pausamos el cambio para evitar errores de API/GCD.
    -- (Si combatHideMounted está activo, el frame seguirá visible pero estático).
    if UnitAffectingCombat("player") or UnitChannelInfo("player") or UnitCastingInfo("player") or UnitIsDeadOrGhost("player") then
        return 
    end
    
    -- V1.6.0 Automation Triggers
    if self.db.profile.pauseInStealth and IsStealthed() then return end
    if self.db.profile.pauseInResting and IsResting() then return end
    if self.db.profile.pauseInInstance and IsInInstance() then return end
    if self.db.profile.pauseTargetEnemy and IsEnemyTarget() then return end

    local type1Name = self:GetType1()
    local type2Name = self:GetType2()

    -- Validación básica
    if not type1Name or type1Name == "" then return end
    -- Si type2 no está definido, no hacemos toggle, solo mantenemos type1
    if not type2Name or type2Name == "" then
         if not self:IsTrackingActive(type1Name) then self:SetTrackingByName(type1Name) end
         return
    end

    -- Lógica de conmutación
    local targetName = nil
    
    -- Verificamos si el TIPO 1 está activo
    local isType1Active = self:IsTrackingActive(type1Name)

    if not isType1Active then
        -- Si Type1 NO está activo -> Activarlo
        targetName = type1Name
    else
        -- Si Type1 SI está activo -> Cambiar a Type2
        targetName = type2Name
    end

    -- V1.6.0 Debug: Diagnóstico en combate
    if inCombat and allowCombat then
        -- print("Combate Montado: Intentando cambiar a " .. (targetName or "nil"))
    end
    
    local success = self:SetTrackingByName(targetName)
    
    if success then
        self:UpdateGUI()
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
