GatherTracker = LibStub("AceAddon-3.0"):NewAddon("GatherTracker", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")

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

-- Diccionario de Nodos (Simplificado)
local validNodes = {
    -- Minerales
    ["Copper Vein"] = true, ["Filón de cobre"] = true,
    ["Tin Vein"] = true, ["Filón de estaño"] = true,
    ["Silver Vein"] = true, ["Filón de plata"] = true,
    ["Iron Deposit"] = true, ["Depósito de hierro"] = true,
    ["Gold Vein"] = true, ["Filón de oro"] = true,
    ["Mithril Deposit"] = true, ["Depósito de mitril"] = true,
    ["Truesilver Deposit"] = true, ["Depósito de veraplata"] = true,
    ["Thorium Vein"] = true, ["Filón de torio"] = true,
    ["Rich Thorium Vein"] = true, ["Filón de torio rico"] = true,
    -- TBC
    ["Fel Iron Deposit"] = true, ["Depósito de hierro vil"] = true,
    ["Adamantite Deposit"] = true, ["Depósito de adamantita"] = true,
    ["Khorium Vein"] = true, ["Filón de korio"] = true,
    
    -- Items de Minería (Loot)
    ["Copper Ore"] = true, ["Mena de cobre"] = true,
    ["Tin Ore"] = true, ["Mena de estaño"] = true,
    ["Silver Ore"] = true, ["Mena de plata"] = true,
    ["Iron Ore"] = true, ["Mena de hierro"] = true,
    ["Gold Ore"] = true, ["Mena de oro"] = true,
    ["Mithril Ore"] = true, ["Mena de mitril"] = true,
    ["Truesilver Ore"] = true, ["Mena de veraplata"] = true,
    ["Thorium Ore"] = true, ["Mena de torio"] = true,
    ["Fel Iron Ore"] = true, ["Mena de hierro vil"] = true,
    ["Adamantite Ore"] = true, ["Mena de adamantita"] = true,
    ["Khorium Ore"] = true, ["Mena de korio"] = true,
    ["Eternium Ore"] = true, ["Mena de eternio"] = true,
    
    -- Piedras y Gemas de Minería
    ["Rough Stone"] = true, ["Piedra férrea"] = true,
    ["Coarse Stone"] = true, ["Piedra burda"] = true,
    ["Heavy Stone"] = true, ["Piedra pesada"] = true,
    ["Solid Stone"] = true, ["Piedra sólida"] = true,
    ["Dense Stone"] = true, ["Piedra densa"] = true,
    ["Malachite"] = true, ["Malaquita"] = true,
    ["Tigerseye"] = true, ["Ojo de tigre"] = true,
    ["Shadowgem"] = true, ["Gema de las sombras"] = true,
    ["Moss Agate"] = true, ["Ágata musgosa"] = true,
    ["Lesser Moonstone"] = true, ["Piedra lunar inferior"] = true,
    ["Jade"] = true, -- Igual en ES/EN
    ["Citrine"] = true, ["Citrino"] = true,
    ["Aquamarine"] = true, ["Aguamarina"] = true,
    ["Azerothian Diamond"] = true, ["Diamante de Azeroth"] = true,
    ["Blue Sapphire"] = true, ["Zafiro azul"] = true,
    ["Large Opal"] = true, ["Ópalo grande"] = true,
    ["Huge Emerald"] = true, ["Esmeralda enorme"] = true,
    ["Arcane Crystal"] = true, ["Cristal arcano"] = true,
    
    -- Hierbas
    ["Peacebloom"] = true, ["Flor de paz"] = true,
    ["Silverleaf"] = true, ["Hoja de plata"] = true,
    ["Earthroot"] = true, ["Raíz de tierra"] = true,
    ["Mageroyal"] = true, ["Marregal"] = true,
    ["Briarthorn"] = true, ["Brezospina"] = true,
    ["Bruiseweed"] = true, ["Hierba cardenal"] = true,
    ["Wild Steelbloom"] = true, ["Aceream"] = true,
    ["Grave Moss"] = true, ["Musgo de tumba"] = true,
    ["Kingsblood"] = true, ["Sangrerregia"] = true,
    ["Liferoot"] = true, ["Vidarraíz"] = true,
    ["Fadeleaf"] = true, ["Pálida"] = true,
    ["Goldthorn"] = true, ["Espina de oro"] = true,
    ["Khadgar's Whisker"] = true, ["Bigote de Khadgar"] = true,
    ["Wintersbite"] = true, ["Mordedura de invierno"] = true,
    ["Firebloom"] = true, ["Flor de fuego"] = true,
    ["Purple Lotus"] = true, ["Loto cárdeno"] = true,
    ["Arthas' Tears"] = true, ["Lágrimas de Arthas"] = true,
    ["Sungrass"] = true, ["Solea"] = true,
    ["Blindweed"] = true, ["Ciega"] = true,
    ["Ghost Mushroom"] = true, ["Champiñón fantasma"] = true,
    ["Gromsblood"] = true, ["Gromsanguina"] = true,
    ["Golden Sansam"] = true, ["Sansam dorado"] = true,
    ["Dreamfoil"] = true, ["Hoja de sueño"] = true,
    ["Mountain Silversage"] = true, ["Salvia de montaña"] = true,
    ["Plaguebloom"] = true, ["Flor de peste"] = true,
    ["Icecap"] = true, ["Setelo"] = true,
    ["Black Lotus"] = true, ["Loto negro"] = true,
    -- TBC Herbs
    ["Felweed"] = true, ["Hierba vil"] = true,
    ["Dreaming Glory"] = true, ["Gloria de ensueño"] = true,
    ["Ragveil"] = true, ["Velada"] = true,
    ["Terocone"] = true, ["Terocono"] = true,
    ["Ancient Lichen"] = true, ["Liquen antiguo"] = true,
    ["Netherbloom"] = true, ["Flor abisal"] = true,
    ["Nightmare Vine"] = true, ["Vid de pesadilla"] = true,
    ["Mana Thistle"] = true, ["Cardo de maná"] = true,
}

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
        type1 = { order = 2, name = "Rastreo Primario", type = "select", values = classTrackingValues, get = 'GetType1', set = 'SetType1' },
        type2 = { order = 3, name = "Rastreo Secundario", type = "select", values = classTrackingValues, get = 'GetType2', set = 'SetType2' },
        castInterval = { order = 4, name = "Intervalo (segundos)", type = "range", min = 2, max = 60, step = 1, get = 'GetCastInterval', set = 'SetCastInterval', width = "full" },
        showFrame = { order = 5, name = "Mostrar Botón Flotante", type = "toggle", get = 'GetShowFrame', set = 'SetShowFrame', width = "full" },
        headerAuto = { order = 6, type = "header", name = "Automatización" },
        autoSell = { order = 7, name = "Auto-Vender Grises", desc = "Vende automáticamente objetos de calidad gris al visitar un comerciante.", type = "toggle", get = 'GetAutoSell', set = 'SetAutoSell', width = "full" },
        combatHide = { order = 8, name = "Ocultar en Combate", desc = "Oculta el botón y pausa el rastreo al entrar en combate.", type = "toggle", get = 'GetCombatHide', set = 'SetCombatHide', width = "full" },
        resumeAfterCombat = { order = 9, name = "Autoreanudar tras Combate", desc = "Si está activado, el rastreo se volverá a iniciar automáticamente al salir de combate.", type = "toggle", get = 'GetResumeAfterCombat', set = 'SetResumeAfterCombat', width = "full" },
        soundAlerts = { order = 10, name = "Alertas de Sonido", desc = "Reproduce un sonido al detectar un nodo (Requiere detección avanzada).", type = "toggle", get = 'GetSoundAlerts', set = 'SetSoundAlerts', width = "full" },
    }
}

local defaults = {
    profile  = {
        type1 = "minerals", type2 = "herbs", castInterval = 2,
        showFrame = true,
        autoSell = false,
        combatHide = true,
        resumeAfterCombat = false, -- Por defecto desactivado como se pidió (opcional)
        soundAlerts = false,
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
            if IsShiftKeyDown() then
                GatherTracker:AnnounceLastNode()
            else
                GatherTracker:ToggleTracking()
            end
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
    self.db = LibStub("AceDB-3.0"):New("GatherTrackerCharDB", defaults, true)
    LibStub('AceConfig-3.0'):RegisterOptionsTable('GatherTracker', options)
    self.optionsFrame = LibStub('AceConfigDialog-3.0'):AddToBlizOptions('GatherTracker', 'GatherTracker')
    
    self:RegisterChatCommand('gt', 'ChatCommand')
    
    -- Eventos
    self:RegisterEvent("MINIMAP_UPDATE_TRACKING")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatEnter")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatLeave")
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("MERCHANT_SHOW", "OnMerchantShow")
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckProfessionsDelayed")
    self:RegisterEvent("SKILL_LINES_CHANGED", "CheckProfessions")
    
    if not self.db.profile.type1 then self.db.profile.type1 = "minerals" end
    if not self.db.profile.type2 then self.db.profile.type2 = "herbs" end
    if not self.db.profile.castInterval then self.db.profile.castInterval = 2 end
    
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
    GameTooltip:AddLine(" ")
    
    -- Sección de Loot
    GameTooltip:AddLine("Sesión de Farm:", 0, 1, 1)
    
    local hasLoot = false
    -- Cabecera
    GameTooltip:AddDoubleLine("Item (Cant)", "Venta | AH", 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
    
    -- Inicializar totales
    local sUnits, sVendor, sAH = 0, 0, 0
    local bUnits, bVendor, bAH = 0, 0, 0
    
    for id, data in pairs(GatherTracker.lootSession) do
        hasLoot = true
        
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
        
        GameTooltip:AddDoubleLine(data.name .. " x" .. data.count, totalVendor .. " | " .. totalAH, 1, 1, 1, 1, 1, 1)
    end
    
    if not hasLoot then
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
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("|cffFFFFFFClic Izq:|r Activar/Pausar")
    GameTooltip:AddLine("|cffFFFFFFRueda:|r Ajustar Tiempo")
    GameTooltip:AddLine("|cffFFFFFFClic Der:|r Opciones")
    GameTooltip:Show()
end

function GatherTracker:MINIMAP_UPDATE_TRACKING()
    self:UpdateGUI()
end

function GatherTracker:OnCombatEnter()
    self.inCombat = true
    if self.db.profile.combatHide then
        if self.frame then self.frame:Hide() end
    end
    self:StopTimer()
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


function GatherTracker:CheckProfessions()
    -- Variables locales para esta ejecución
    local foundMining = false
    local foundHerbalism = false

    -- 1. Método Moderno (GetProfessions)
    local prof1, prof2, arch, fish, cook, firstAid = GetProfessions()
    local function CheckID(index)
        if not index then return end
        local _, _, _, _, _, _, skillLineID = GetProfessionInfo(index)
        if skillLineID == 186 then foundMining = true end
        if skillLineID == 182 then foundHerbalism = true end
    end
    CheckID(prof1)
    CheckID(prof2)

    -- 2. Fallback Universal (Scan Skill Lines) si GetProfessions falló
    if not (foundMining or foundHerbalism) then
        local miningName = GetSpellInfo(2575)
        local herbalismName = GetSpellInfo(9134)
        
        for i = 1, GetNumSkillLines() do
            local name, header = GetSkillLineInfo(i)
            if not header then
                if miningName and (name == miningName or name == "Mining") then foundMining = true end
                if herbalismName and (name == herbalismName or name == "Herbalism") then foundHerbalism = true end
            end
        end
    end
    
    -- Actualizar configuración y notificar SOLO si hubo cambios
    local sig = (foundMining and "M" or "") .. (foundHerbalism and "H" or "")
    if self.lastDetectedSig == sig then return end -- No imprimir si no ha cambiado nada
    self.lastDetectedSig = sig
    
    -- Aplicar cambios
    if foundMining then self.db.profile.type1 = "minerals" end
    if foundHerbalism then self.db.profile.type2 = "herbs" end
    
    -- Mensaje (Solo una vez por cambio)
    if foundMining or foundHerbalism then
        local msg = "|cff00ff00GatherTracker:|r Profesiones detectadas:"
        if foundMining then msg = msg .. " Minería" end
        if foundHerbalism then msg = msg .. " Herboristería" end
        -- Evitar spam inicial si ya estaba configurado igual, pero el usuario quiere verlo al loguear.
        -- Como hemos comprobado 'sig', solo saldrá al loguear (nil -> sig) y si cambia.
        print(msg)
    else
        -- Opcional: Notificar si no se detectó nada (solo si tenía algo antes)
        if self.lastDetectedSig ~= "" then
            print("|cff00ff00GatherTracker:|r No se detectaron profesiones de recolección.")
        end
    end
end

-- Eliminamos el delayed wrapper complejo, confiamos en SKILL_LINES_CHANGED
function GatherTracker:CheckProfessionsDelayed()
    -- Compatibility stub if needed
end

-- Getters y Setters adicionales
function GatherTracker:GetAutoSell() return self.db.profile.autoSell end
function GatherTracker:SetAutoSell(info, val) self.db.profile.autoSell = val end

function GatherTracker:GetCombatHide() return self.db.profile.combatHide end
function GatherTracker:SetCombatHide(info, val) self.db.profile.combatHide = val end

function GatherTracker:GetSoundAlerts() return self.db.profile.soundAlerts end
function GatherTracker:SetSoundAlerts(info, val) self.db.profile.soundAlerts = val end

function GatherTracker:GetResumeAfterCombat() return self.db.profile.resumeAfterCombat end
function GatherTracker:SetResumeAfterCombat(info, val) self.db.profile.resumeAfterCombat = val end


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
