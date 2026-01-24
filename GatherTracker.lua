GatherTracker = LibStub("AceAddon-3.0"):NewAddon("GatherTracker", "AceTimer-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherTracker")

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


-- ID UNIVERSAL LIST (Categorized for v1.7.1)
-- Static Popup Dialog (v1.7.1 Security)
StaticPopupDialogs["GT_RESET_CONFIRM"] = {
    text = L["RESET_CONFIRM_TEXT"],
    button1 = L["RESET_BUTTON_YES"],
    button2 = L["RESET_BUTTON_NO"],
    OnAccept = function()
        GatherTracker:ResetDatabase()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local miningIDs = {
    -- Classic Ores
    [2770] = true, [2771] = true, [2775] = true, [2772] = true, [2776] = true,
    [3858] = true, [7911] = true, [10620] = true, [11370] = true, [12363] = true,
    -- TBC Ores
    [23424] = true, [23425] = true, [23426] = true, [23427] = true,
    -- Stones
    [2835] = true, [2836] = true, [2838] = true, [7912] = true, [12365] = true,
}

local herbIDs = {
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

local gemIDs = {
    -- Classic Gems
    [774] = true, [1206] = true, [1210] = true, [1225] = true, [1705] = true, 
    [5489] = true, [3864] = true, [7909] = true, [12799] = true, [7910] = true, 
    [7907] = true, [12800] = true, 
    -- TBC Gems
    [23077] = true, [23076] = true, [23073] = true, [23071] = true,
    [23072] = true, [23074] = true, [25867] = true, [25868] = true,
}

local fishingIDs = {
    -- Classic Fish
    [6290] = true, [6289] = true, [6522] = true, [6308] = true, [6317] = true,
    [6358] = true, [6359] = true, [13422] = true,
    -- TBC Fish
    [27422] = true, [27425] = true, [27429] = true, [27430] = true, [27431] = true,
    [27432] = true
}

local validItemIDs = {}
for k,v in pairs(miningIDs) do validItemIDs[k] = true end
for k,v in pairs(herbIDs) do validItemIDs[k] = true end
for k,v in pairs(gemIDs) do validItemIDs[k] = true end
for k,v in pairs(fishingIDs) do validItemIDs[k] = true end

-- Lista de Logros (Gamification v1.7.0)
-- Lista de Logros (Gamification v1.7.3)
-- Campos: id, req_type, req_key, threshold, name, desc, icon, category, points
local achievementsList = {
    -- GENERAL (Total Items)
    { category="CAT_GENERAL", id=1, req_type="total", threshold=100, points=5, name="ACH_NOVATO_NAME", desc="ACH_NOVATO_DESC", icon="Interface\\Icons\\Inv_misc_bag_10" },
    { category="CAT_GENERAL", id=2, req_type="total", threshold=500, points=5, name="ACH_APRENDIZ_NAME", desc="ACH_APRENDIZ_DESC", icon="Interface\\Icons\\Inv_misc_bag_09" },
    { category="CAT_GENERAL", id=3, req_type="total", threshold=1000, points=10, name="ACH_OFICIAL_NAME", desc="ACH_OFICIAL_DESC", icon="Interface\\Icons\\Inv_misc_bag_19" },
    { category="CAT_GENERAL", id=4, req_type="total", threshold=2500, points=10, name="ACH_EXPERTO_NAME", desc="ACH_EXPERTO_DESC", icon="Interface\\Icons\\Inv_misc_bag_27" },
    { category="CAT_GENERAL", id=5, req_type="total", threshold=5000, points=20, name="ACH_MAESTRO_NAME", desc="ACH_MAESTRO_DESC", icon="Interface\\Icons\\Inv_misc_bag_10_red" },
    { category="CAT_GENERAL", id=6, req_type="total", threshold=10000, points=50, name="ACH_GRAN_MAESTRO_NAME", desc="ACH_GRAN_MAESTRO_DESC", icon="Interface\\Icons\\Inv_misc_bag_10_green" },
    { category="CAT_GENERAL", id=7, req_type="total", threshold=25000, points=100, name="ACH_LEYENDA_NAME", desc="ACH_LEYENDA_DESC", icon="Interface\\Icons\\Inv_misc_bag_10_blue" },

    -- MINERÍA
    { category="CAT_MINING", id=8, req_type="category_count", req_key="CAT_MINING", threshold=1, points=5, name="ACH_PRIMERA_PIEDRA_NAME", desc="ACH_PRIMERA_PIEDRA_DESC", icon="Interface\\Icons\\Inv_stone_01" },
    { category="CAT_MINING", id=9, req_type="category_count", req_key="CAT_MINING", threshold=10, points=5, name="ACH_SUCIO_NAME", desc="ACH_SUCIO_DESC", icon="Interface\\Icons\\Inv_misc_dust_01" },
    { category="CAT_MINING", id=10, req_type="category_count", req_key="CAT_MINING", threshold=50, points=5, name="ACH_PICAPIEDRA_NAME", desc="ACH_PICAPIEDRA_DESC", icon="Interface\\Icons\\Inv_pick_01" },
    { category="CAT_MINING", id=11, req_type="category_count", req_key="CAT_MINING", threshold=100, points=5, name="ACH_MINERO_COBRE_NAME", desc="ACH_MINERO_COBRE_DESC", icon="Interface\\Icons\\Inv_ore_copper_01" },
    { category="CAT_MINING", id=12, req_type="category_count", req_key="CAT_MINING", threshold=250, points=10, name="ACH_MINERO_HIERRO_NAME", desc="ACH_MINERO_HIERRO_DESC", icon="Interface\\Icons\\Inv_ore_iron_01" },
    { category="CAT_MINING", id=13, req_type="category_count", req_key="CAT_MINING", threshold=500, points=10, name="ACH_MINERO_MITRIL_NAME", desc="ACH_MINERO_MITRIL_DESC", icon="Interface\\Icons\\Inv_ore_mithril_01" },
    { category="CAT_MINING", id=14, req_type="category_count", req_key="CAT_MINING", threshold=1000, points=20, name="ACH_MINERO_TORIO_NAME", desc="ACH_MINERO_TORIO_DESC", icon="Interface\\Icons\\Inv_ore_thorium_01" },
    { category="CAT_MINING", id=15, req_type="category_count", req_key="CAT_MINING", threshold=2500, points=20, name="ACH_MINERO_ARCANO_NAME", desc="ACH_MINERO_ARCANO_DESC", icon="Interface\\Icons\\Inv_misc_gem_crystal_01" },
    { category="CAT_MINING", id=16, req_type="category_count", req_key="CAT_MINING", threshold=5000, points=50, name="ACH_SENOR_ROCA_NAME", desc="ACH_SENOR_ROCA_DESC", icon="Interface\\Icons\\Trade_mining" },

    -- HERBORISTERÍA
    { category="CAT_HERBALISM", id=18, req_type="category_count", req_key="CAT_HERBALISM", threshold=1, points=5, name="ACH_UNA_FLOR_NAME", desc="ACH_UNA_FLOR_DESC", icon="Interface\\Icons\\Inv_misc_flower_01" },
    { category="CAT_HERBALISM", id=19, req_type="category_count", req_key="CAT_HERBALISM", threshold=10, points=5, name="ACH_RAMO_NAME", desc="ACH_RAMO_DESC", icon="Interface\\Icons\\Inv_misc_flower_02" },
    { category="CAT_HERBALISM", id=20, req_type="category_count", req_key="CAT_HERBALISM", threshold=50, points=5, name="ACH_JARDINERO_NAME", desc="ACH_JARDINERO_DESC", icon="Interface\\Icons\\Inv_misc_flower_02" },
    { category="CAT_HERBALISM", id=21, req_type="category_count", req_key="CAT_HERBALISM", threshold=100, points=5, name="ACH_FLORISTA_NAME", desc="ACH_FLORISTA_DESC", icon="Interface\\Icons\\Inv_misc_herb_01" },
    { category="CAT_HERBALISM", id=22, req_type="category_count", req_key="CAT_HERBALISM", threshold=250, points=10, name="ACH_HERBORISTA_NAME", desc="ACH_HERBORISTA_DESC", icon="Interface\\Icons\\inv_misc_herb_sansamroot" },
    { category="CAT_HERBALISM", id=23, req_type="category_count", req_key="CAT_HERBALISM", threshold=500, points=10, name="ACH_BOTANISTA_NAME", desc="ACH_BOTANISTA_DESC", icon="Interface\\Icons\\inv_misc_herb_dreamfoil" },
    { category="CAT_HERBALISM", id=24, req_type="category_count", req_key="CAT_HERBALISM", threshold=1000, points=20, name="ACH_DRUIDA_NAME", desc="ACH_DRUIDA_DESC", icon="Interface\\Icons\\inv_misc_herb_mountainsilversage" },
    { category="CAT_HERBALISM", id=25, req_type="category_count", req_key="CAT_HERBALISM", threshold=2500, points=20, name="ACH_GUARDIAN_NAME", desc="ACH_GUARDIAN_DESC", icon="Interface\\Icons\\inv_misc_herb_icecap" },

    -- PESCA
    { category="CAT_FISHING", id=28, req_type="category_count", req_key="CAT_FISHING", threshold=1, points=5, name="ACH_PRIMER_PEZ_NAME", desc="ACH_PRIMER_PEZ_DESC", icon="Interface\\Icons\\Inv_misc_fish_01" },
    { category="CAT_FISHING", id=29, req_type="category_count", req_key="CAT_FISHING", threshold=10, points=5, name="ACH_CENA_NAME", desc="ACH_CENA_DESC", icon="Interface\\Icons\\Inv_misc_fish_02" },
    { category="CAT_FISHING", id=30, req_type="category_count", req_key="CAT_FISHING", threshold=25, points=5, name="ACH_PESCADOR_CHARCA_NAME", desc="ACH_PESCADOR_CHARCA_DESC", icon="Interface\\Icons\\Inv_misc_fish_01" },
    { category="CAT_FISHING", id=31, req_type="category_count", req_key="CAT_FISHING", threshold=50, points=5, name="ACH_PESCADOR_RIO_NAME", desc="ACH_PESCADOR_RIO_DESC", icon="Interface\\Icons\\Inv_misc_fish_02" },
    { category="CAT_FISHING", id=32, req_type="category_count", req_key="CAT_FISHING", threshold=100, points=10, name="ACH_PESCADOR_MAR_NAME", desc="ACH_PESCADOR_MAR_DESC", icon="Interface\\Icons\\Inv_misc_fish_03" },
    { category="CAT_FISHING", id=33, req_type="category_count", req_key="CAT_FISHING", threshold=250, points=10, name="ACH_LOBO_MAR_NAME", desc="ACH_LOBO_MAR_DESC", icon="Interface\\Icons\\Inv_misc_fish_turtle_01" },
    { category="CAT_FISHING", id=34, req_type="category_count", req_key="CAT_FISHING", threshold=500, points=20, name="ACH_MAESTRO_PESCADOR_NAME", desc="ACH_MAESTRO_PESCADOR_DESC", icon="Interface\\Icons\\Trade_Fishing" },

    -- GEMAS & PIEDRAS
    { category="CAT_TREASURES", id=40, req_type="category_count", req_key="CAT_TREASURES", threshold=10, points=5, name="ACH_BRILLANTE_NAME", desc="ACH_BRILLANTE_DESC", icon="Interface\\Icons\\inv_misc_gem_emerald_02" },
    { category="CAT_TREASURES", id=41, req_type="category_count", req_key="CAT_TREASURES", threshold=50, points=10, name="ACH_JOYERO_NAME", desc="ACH_JOYERO_DESC", icon="Interface\\Icons\\inv_misc_gem_diamond_01" },
    { category="CAT_TREASURES", id=42, req_type="category_count", req_key="CAT_TREASURES", threshold=100, points=20, name="ACH_APARICIONES_NAME", desc="ACH_APARICIONES_DESC", icon="Interface\\Icons\\inv_misc_gem_opal_01" },
    { category="CAT_TREASURES", id=45, req_type="item_id", req_key=12363, threshold=10, points=20, name="ACH_ARCANISTA_NAME", desc="ACH_ARCANISTA_DESC", icon="Interface\\Icons\\Inv_misc_gem_crystal_01" },

    -- ECONOMÍA (Valor Estimado Venta NPC)
    { category="CAT_ECONOMY", id=50, req_type="total_value", threshold=100000, points=5, name="ACH_AHORRADOR_NAME", desc="ACH_AHORRADOR_DESC", icon="Interface\\Icons\\inv_misc_coin_01" },
    { category="CAT_ECONOMY", id=51, req_type="total_value", threshold=500000, points=10, name="ACH_MERCADER_NAME", desc="ACH_MERCADER_DESC", icon="Interface\\Icons\\inv_misc_coin_03" },
    { category="CAT_ECONOMY", id=52, req_type="total_value", threshold=1000000, points=10, name="ACH_BURGUES_NAME", desc="ACH_BURGUES_DESC", icon="Interface\\Icons\\inv_misc_coin_05" },
    { category="CAT_ECONOMY", id=53, req_type="total_value", threshold=5000000, points=20, name="ACH_MAGNATE_NAME", desc="ACH_MAGNATE_DESC", icon="Interface\\Icons\\inv_misc_coin_06" },
    { category="CAT_ECONOMY", id=54, req_type="total_value", threshold=10000000, points=50, name="ACH_MILLONARIO_NAME", desc="ACH_MILLONARIO_DESC", icon="Interface\\Icons\\Inv_Box_01" },

    -- ESPECÍFICOS (Hardcore v1.7.4)
    { category="CAT_SPECIALIST", id=101, req_type="item_id", req_key=2770, threshold=200, points=10, name="ACH_EDAD_COBRE_NAME", desc="ACH_EDAD_COBRE_DESC", icon="Interface\\Icons\\Inv_ore_copper_01" },
    { category="CAT_SPECIALIST", id=102, req_type="item_id", req_key=2772, threshold=200, points=10, name="ACH_VOLUNTAD_HIERRO_NAME", desc="ACH_VOLUNTAD_HIERRO_DESC", icon="Interface\\Icons\\Inv_ore_iron_01" },
    { category="CAT_SPECIALIST", id=103, req_type="item_id", req_key=10620, threshold=200, points=30, name="ACH_PODER_TORIO_NAME", desc="ACH_PODER_TORIO_DESC", icon="Interface\\Icons\\Inv_ore_thorium_02" },
    
    -- Hardcore (New v1.7.4)
    { category="CAT_SPECIALIST", id=110, req_type="item_id", req_key=11370, threshold=200, points=50, name="ACH_CORAZON_OSCURO_NAME", desc="ACH_CORAZON_OSCURO_DESC", icon="Interface\\Icons\\Inv_ore_mithril_01" },
    { category="CAT_SPECIALIST", id=111, req_type="item_id", req_key=13466, threshold=200, points=50, name="ACH_PESTE_LATENTE_NAME", desc="ACH_PESTE_LATENTE_DESC", icon="Interface\\Icons\\Inv_misc_herb_13" },
    { category="CAT_SPECIALIST", id=112, req_type="item_id", req_key=13465, threshold=200, points=50, name="ACH_SABIO_MONTANA_NAME", desc="ACH_SABIO_MONTANA_DESC", icon="Interface\\Icons\\inv_misc_herb_mountainsilversage" },
    { category="CAT_SPECIALIST", id=113, req_type="item_id", req_key=13464, threshold=200, points=40, name="ACH_SUENO_ETERNO_NAME", desc="ACH_SUENO_ETERNO_DESC", icon="Interface\\Icons\\Inv_misc_herb_12" },
    { category="CAT_SPECIALIST", id=114, req_type="item_id", req_key=13422, threshold=200, points=50, name="ACH_ESCAMA_DURA_NAME", desc="ACH_ESCAMA_DURA_DESC", icon="Interface\\Icons\\inv_misc_fish_21" },
}

-- ============================================================================
-- 2. CONFIGURACIÓN DEL MENÚ
-- ============================================================================
local options = {
    name = 'GatherTracker', handler = GatherTracker, type = 'group',
    args = {
        header = { order = 1, type = "header", name = L["OPT_HEADER_TRACKING"] },
        type1 = { order = 2, name = L["OPT_PRI_TRACKING"], type = "select", values = function() return availableTrackingTypes end, get = 'GetType1', set = 'SetType1' },
        type2 = { order = 3, name = L["OPT_SEC_TRACKING"], type = "select", values = function() return availableTrackingTypes end, get = 'GetType2', set = 'SetType2' },
        castInterval = { order = 4, name = L["OPT_INTERVAL"], type = "range", min = 2, max = 60, step = 1, get = 'GetCastInterval', set = 'SetCastInterval', width = "full" },
        showFrame = { order = 5, name = L["OPT_SHOW_FRAME"], type = "toggle", get = 'GetShowFrame', set = 'SetShowFrame', width = "full" },
        muteSound = { order = 6, name = L["OPT_MUTE_SOUND"], desc = L["OPT_MUTE_SOUND_DESC"], type = "toggle", get = 'GetMuteSound', set = 'SetMuteSound' },
        
        -- v1.7.3 Social
        announceGuild = { order = 7, name = L["OPT_ANNOUNCE_GUILD"], desc = L["OPT_ANNOUNCE_GUILD_DESC"], type = "toggle", get = 'GetAnnounceGuild', set = 'SetAnnounceGuild', width = "full" },

        headerInfo = { order = 10, type = "header", name = L["OPT_HEADER_TOOLTIP"] },
        showDurability = { order = 11, name = L["OPT_SHOW_DURABILITY"], type = "toggle", get = 'GetShowDurability', set = 'SetShowDurability' },
        showSkillLevel = { order = 12, name = L["OPT_SHOW_SKILL"], type = "toggle", get = 'GetShowSkillLevel', set = 'SetShowSkillLevel' },

        headerAuto = { order = 20, type = "header", name = L["OPT_HEADER_AUTO"] },
        autoSell = { order = 21, name = L["OPT_AUTO_SELL"], desc = L["OPT_AUTO_SELL_DESC"], type = "toggle", get = 'GetAutoSell', set = 'SetAutoSell', width = "full" },
        combatHide = { order = 22, name = L["OPT_COMBAT_HIDE"], desc = L["OPT_COMBAT_HIDE_DESC"], type = "toggle", get = 'GetCombatHide', set = 'SetCombatHide' },
        combatHideMounted = { order = 23, name = L["OPT_COMBAT_HIDE_MOUNTED"], desc = L["OPT_COMBAT_HIDE_MOUNTED_DESC"], type = "toggle", get = 'GetCombatHideMounted', set = 'SetCombatHideMounted', disabled = function() return not GatherTracker.db.profile.combatHide end },
        resumeAfterCombat = { order = 24, name = L["OPT_RESUME_AFTER_COMBAT"], desc = L["OPT_RESUME_AFTER_COMBAT_DESC"], type = "toggle", get = 'GetResumeAfterCombat', set = 'SetResumeAfterCombat', width = "full" },
        
        headerPause = { order = 30, type = "header", name = L["OPT_HEADER_PAUSE"] },
        pauseInStealth = { order = 31, name = L["OPT_PAUSE_STEALTH"], type = "toggle", get = 'GetPauseInStealth', set = 'SetPauseInStealth' },
        pauseInResting = { order = 32, name = L["OPT_PAUSE_RESTING"], type = "toggle", get = 'GetPauseInResting', set = 'SetPauseInResting' },
        pauseTargetEnemy = { order = 33, name = L["OPT_PAUSE_ENEMY"], type = "toggle", get = 'GetPauseTargetEnemy', set = 'SetPauseTargetEnemy' },
        pauseInInstance = { order = 34, name = L["OPT_PAUSE_INSTANCE"], type = "toggle", get = 'GetPauseInInstance', set = 'SetPauseInInstance' },

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
        combatHideMounted = false,
        announceGuild = false -- v1.7.3
    },
    global = {
        history = {
            totalItems = 0,
            items = {},
            achievements = {}
        }
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
                GatherTracker:CreateHistoryUI()
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
        GameTooltip:AddLine(L["STATUS_LABEL"] .. " |cff00ff00" .. L["ACTIVE"] .. "|r", 1, 1, 1)
    else
        GameTooltip:AddLine(L["STATUS_LABEL"] .. " |cffff0000" .. L["PAUSED"] .. "|r", 1, 1, 1)
    end
    
    GameTooltip:AddLine(" ")
    -- Mostramos el tiempo actual en amarillo destacado
    GameTooltip:AddDoubleLine(L["INTERVAL_LABEL"], "|cffFFFF00" .. GatherTracker:GetCastInterval() .. " seg|r")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["LEFT_CLICK_HINT"])
    GameTooltip:AddLine(L["MOUSE_WHEEL_HINT"])
    GameTooltip:AddLine(L["RIGHT_CLICK_HINT"])
    GameTooltip:AddLine(L["ALT_DRAG_HINT"])
    GameTooltip:AddLine(L["SHIFT_CLICK_HINT"])
    GameTooltip:Show()
    
    -- Sección de Historial
    if #GatherTracker.nodeHistory > 0 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["RECENT_HISTORY"], 0, 1, 1)
        local now = GetTime()
        for i, node in ipairs(GatherTracker.nodeHistory) do
            local diff = now - node.time
            if diff < 120 then -- Mostrar solo últimos 2 min
                local timeStr = ""
                if diff < 60 then timeStr = math.floor(diff).."s"
                else timeStr = math.floor(diff/60).."m" end
                GameTooltip:AddDoubleLine(node.name, L["AGO"] .. " " .. timeStr, 1, 1, 1, 0.7, 0.7, 0.7)
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
-- 3.1 GATHERMASTER UI (v1.7.0)
-- ============================================================================

function GatherTracker:CreateHistoryUI()
    if self.historyFrame then
        if self.historyFrame:IsShown() then self.historyFrame:Hide() else self.historyFrame:Show() end
        return
    end
    
    local f = CreateFrame("Frame", "GatherTrackerHistoryFrame", UIParent, "BackdropTemplate")
    f:SetSize(450, 420) -- Expanded size
    f:SetPoint("CENTER")
    -- v1.7.5: Flat Dark Theme (AceConfig Style)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.95) -- Casi negro absoluto
    f:SetBackdropBorderColor(0.5, 0.5, 0.5, 1) -- Borde grisáceo
    
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    -- Close Button
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    
    -- Title
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", 0, -15)
    f.title:SetText(L["TROPHY_ROOM_TITLE"])
    
    -- Stats
    f.stats = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.stats:SetPoint("TOPLEFT", 25, -45)
    
    -- Points Display (v1.7.3)
    f.points = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    f.points:SetPoint("TOPRIGHT", -25, -45)
    f.points:SetText(L["POINTS_LABEL"] .. " 0")
    
    -- Reset Button (v1.7.1 Safe Reset)
    f.resetBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.resetBtn:SetSize(100, 25)
    f.resetBtn:SetPoint("BOTTOMLEFT", 20, 15)
    f.resetBtn:SetText(L["DELETE_DATA_BTN"])
    f.resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("GT_RESET_CONFIRM")
    end)
    
    -- ScrollFrame
    local sf = CreateFrame("ScrollFrame", "GatherTrackerHistoryScroll", f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 20, -70)
    sf:SetPoint("BOTTOMRIGHT", -40, 50) -- Más espacio para el botón abajo
    
    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(380, 800) -- Alto dinámico sería ideal, pero fijo alto funciona si es suficiente
    sf:SetScrollChild(content)
    
    -- Achievements Grid (v1.7.2 Dynamic Headers)
    f.achievements = {}
    local x, y = 10, -10
    local col = 0
    local lastCat = ""
    
    for i, ach in ipairs(achievementsList) do
        -- Check Category Change
        local thisCat = ach.category or "Otros"
        if thisCat ~= lastCat then
            -- Nueva Línea
            if col > 0 then
                 col = 0
                 x = 10
                 y = y - 60
            end
            
            -- Header
            y = y - 10
            local header = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
            header:SetPoint("TOPLEFT", x + 5, y)
            header:SetText(L[thisCat] or thisCat)
            y = y - 25 -- Espacio bajo header
            lastCat = thisCat
        end
        
        local btn = CreateFrame("Button", nil, content, "ItemButtonTemplate")
        btn:SetPoint("TOPLEFT", x, y)
        SetItemButtonTexture(btn, ach.icon)
        
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local h = GatherTracker.db.global.history
            local unlocked = h and h.achievements[ach.id]
            
            GameTooltip:AddLine(L[ach.name])
            GameTooltip:AddLine(L[ach.desc], 1, 1, 1)
            GameTooltip:AddDoubleLine(L["VALUE_LABEL"], (ach.points or 0) .. " Ptos", 1, 1, 1, 0, 1, 0) -- v1.7.3 Points in Tooltip
            
            -- Progress Calculation
            local current = 0
            if ach.req_type == "total" then 
                current = h.totalItems or 0
            elseif ach.req_type == "item_id" then 
                current = h.items[ach.req_key] or 0
            elseif ach.req_type == "category_count" then
                -- Calc on fly for tooltip
                for id, count in pairs(h.items) do
                    if GatherTracker:GetItemCategory(id) == ach.req_key then
                        current = current + count
                    end
                end
            elseif ach.req_type == "total_value" then
                current = h.totalValue or 0
            end
            
            local maxVal = ach.threshold
            local percent = math.min(100, math.floor((current/maxVal)*100))
            
            if ach.req_type == "total_value" then
                 GameTooltip:AddDoubleLine(L["PROGRESS_LABEL"], GetCoinTextureString(current) .. " / " .. GetCoinTextureString(maxVal), 1,1,1, 1,1,0)
            else
                 GameTooltip:AddDoubleLine(L["PROGRESS_LABEL"], current .. " / " .. maxVal .. " ("..percent.."%)", 1,1,1, 1,1,0)
            end

            if unlocked then
                GameTooltip:AddLine("|cff00ff00".. L["UNLOCKED"] .."|r", 1, 1, 1)
            else
                GameTooltip:AddLine("|cffff0000".. L["LOCKED"] .."|r", 1, 1, 1)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        f.achievements[i] = btn
        
        -- Grid 6 columns
        x = x + 50
        col = col + 1
        if col >= 6 then
            col = 0
            x = 10
            y = y - 50
        end
    end
    
    content:SetHeight(math.abs(y) + 60) -- Alto dinámico exacto
    
    -- Auto-Update on Show
    f:SetScript("OnShow", function() GatherTracker:UpdateHistoryUI() end)
    
    self.historyFrame = f
    self:UpdateHistoryUI()
end



function GatherTracker:CreateToastFrame()
    if self.toastFrame then return end
    
    local f = CreateFrame("Frame", "GatherTrackerToast", UIParent, "BackdropTemplate")
    -- v1.7.5: Re-diseño "Heroico" y Alegre
    f:SetSize(300, 70)
    f:SetPoint("TOP", 0, -150)
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border", -- Borde Dorado Brillante
        tile = true, tileSize = 16, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    -- Fondo con tinte azul oscuro para contrastar con el dorado
    f:SetBackdropColor(0.0, 0.1, 0.2, 0.9) 
    f:SetAlpha(0) 
    
    -- Icono Grande
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.icon:SetSize(50, 50)
    f.icon:SetPoint("LEFT", 15, 0)
    f.icon:SetTexture("Interface\\Icons\\Inv_misc_questionmark")
    
    -- Brillo (Glow) detrás del texto (Simulado con textura)
    f.glow = f:CreateTexture(nil, "BACKGROUND")
    f.glow:SetTexture("Interface\\Cooldown\\star4")
    f.glow:SetBlendMode("ADD")
    f.glow:SetAlpha(0.3)
    f.glow:SetPoint("CENTER", f.icon, "CENTER", 0, 0)
    f.glow:SetSize(80, 80)

    -- Texto Título (Grande y Amarillo)
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge") -- Fuente MUY grande
    f.title:SetPoint("TOPLEFT", f.icon, "TOPRIGHT", 15, -10)
    f.title:SetText("|cffFFFF00" .. L["ACHIEVEMENT_UNLOCKED_TITLE"] .. "|r") -- Título corto y directo
    
    -- Texto Nombre (Grande y Blanco)
    f.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.name:SetPoint("BOTTOMLEFT", f.icon, "BOTTOMRIGHT", 15, 10)
    f.name:SetText("Nombre del Logro")
    
    -- Animación (Fade In / Fade Out)
    f.animGroup = f:CreateAnimationGroup()
    
    local fadeIn = f.animGroup:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.5)
    fadeIn:SetOrder(1)
    
    local hold = f.animGroup:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(4.0) -- Mantener 4 segundos
    hold:SetOrder(2)
    
    local fadeOut = f.animGroup:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.5)
    fadeOut:SetOrder(3)
    
    f.animGroup:SetScript("OnFinished", function() f:SetAlpha(0) end)
    
    self.toastFrame = f
end

function GatherTracker:ShowToast(achievementID)
    if not self.toastFrame then self:CreateToastFrame() end
    
    local ach = nil
    for _, a in ipairs(achievementsList) do
        if a.id == achievementID then ach = a; break end
    end
    
    if not ach then return end
    
    self.toastFrame.icon:SetTexture(ach.icon)
    self.toastFrame.name:SetText(L[ach.name])
    
    self.toastFrame:SetAlpha(1) -- Asegurar visibilidad para animación
    self.toastFrame.animGroup:Stop()
    self.toastFrame.animGroup:Play()
    
    PlaySound(878) -- Quest Complete (Motivador y seguro)
end

function GatherTracker:UpdateHistoryUI()
    if not self.historyFrame or not self.historyFrame:IsShown() then return end
    
    local h = self.db.global.history
    if not h then return end
    
    
    local unlockedPoints = 0
    local totalPoints = 0
    
    -- Calc points
    for _, ach in ipairs(achievementsList) do
        totalPoints = totalPoints + (ach.points or 0)
        if h.achievements[ach.id] then
            unlockedPoints = unlockedPoints + (ach.points or 0)
        end
    end
    
        self.historyFrame.stats:SetText(L["TOTAL_ITEMS_STAT"] .. " |cffFFFFFF" .. (h.totalItems or 0) .. "|r")
    
    -- Update Points Text (v1.7.3)
    if self.historyFrame.points then
        local color = "|cffFF0000" -- Rojo
        local pct = 0
        if totalPoints > 0 then pct = unlockedPoints / totalPoints end
        
        if pct > 0.3 then color = "|cffFFFF00" end -- Amarillo
        if pct > 0.7 then color = "|cff00FF00" end -- Verde
        
        self.historyFrame.points:SetText(L["POINTS_LABEL"] .. " " .. color .. unlockedPoints .. "|r / " .. totalPoints)
    end
    
    for i, ach in ipairs(achievementsList) do
        local btn = self.historyFrame.achievements[i]
        local unlocked = h.achievements[ach.id]
        
        if unlocked then
            SetItemButtonDesaturated(btn, false)
            btn.icon:SetVertexColor(1, 1, 1)
        else
            SetItemButtonDesaturated(btn, true)
            btn.icon:SetVertexColor(0.2, 0.2, 0.2)
        end
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
    print("|cff00ff00GatherTracker:|r v" .. (version or "Unknown") .. " " .. L["LOAD_MESSAGE"])
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
    
    -- Actualizar Historial Global (v1.7.0)
    self:UpdateHistory(itemID, count)
end

function GatherTracker:UpdateHistory(itemID, count)
    if not itemID or not count then return end
    
    -- Asegurar inicialización (por si acaso)
    if not self.db.global.history then 
        self.db.global.history = { totalItems = 0, items = {}, achievements = {} } 
    end
    
    local h = self.db.global.history
    h.totalItems = (h.totalItems or 0) + count
    h.items[itemID] = (h.items[itemID] or 0) + count
    
    -- V1.7.2 Value Tracking
    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
    if sellPrice and sellPrice > 0 then
        h.totalValue = (h.totalValue or 0) + (sellPrice * count)
    end
    
    self:CheckAchievements()
    self:UpdateHistoryUI()
end

function GatherTracker:CheckAchievements()
    local h = self.db.global.history
    if not h then return end
    
    -- Pre-calcular totales de categoría para optimizar
    local catTotals = {}
    for id, count in pairs(h.items) do
        local cat = self:GetItemCategory(id)
        catTotals[cat] = (catTotals[cat] or 0) + count
    end
    
    for _, ach in ipairs(achievementsList) do
        local progress = 0
        if ach.req_type == "total" then
            progress = h.totalItems or 0
        elseif ach.req_type == "item_id" then
            progress = h.items[ach.req_key] or 0
        elseif ach.req_type == "category_count" then
            progress = catTotals[ach.req_key] or 0
        elseif ach.req_type == "total_value" then
            progress = h.totalValue or 0
        end
        
        -- Verificar si cumple condición y no estaba desbloqueado
        if progress >= ach.threshold and not h.achievements[ach.id] then
            h.achievements[ach.id] = true
            
            -- Notificación Visual (Toast)
            self:ShowToast(ach.id)
            
            -- Mensaje de respaldo en chat
            print("|cff00ff00[GatherTracker]|r " .. L["CHAT_ACH_UNLOCKED"] .. " " .. L[ach.name] .. " (+" .. (ach.points or 0) .. " pts)")
            
            -- v1.7.3 Social: Guild Announcement
            if self.db.profile.announceGuild and IsInGuild() then
                SendChatMessage("[GatherTracker] " .. L["CHAT_GUILD_ACH"] .. " " .. L[ach.name] .. " ("..(ach.points or 0).." pts)!", "GUILD")
            end
        end
    end
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

-- Helper Category (v1.7.1)
function GatherTracker:GetItemCategory(itemID)
    if not itemID then return "CAT_GENERAL" end
    if miningIDs[itemID] then return "CAT_MINING" end
    if herbIDs[itemID] then return "CAT_HERBALISM" end
    if fishingIDs[itemID] then return "CAT_FISHING" end
    if gemIDs[itemID] then return "CAT_TREASURES" end
    return "CAT_GENERAL"
end

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
        GameTooltip:AddLine(L["STATUS_LABEL"] .. " |cff00ff00" .. L["ACTIVE"] .. "|r", 1, 1, 1)
    else
        GameTooltip:AddLine(L["STATUS_LABEL"] .. " |cffff0000" .. L["PAUSED"] .. "|r", 1, 1, 1)
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(L["INTERVAL_LABEL"], "|cffFFFF00" .. GatherTracker:GetCastInterval() .. " seg|r")

    -- V1.6.0 Info Extra
    if self.db.profile.showDurability then
        local dur = self:GetAverageDurability()
        local r, g, b = 0, 1, 0 -- Verde
        if dur < 30 then r, g, b = 1, 0, 0 -- Rojo
        elseif dur < 70 then r, g, b = 1, 1, 0 end -- Amarillo
        GameTooltip:AddDoubleLine(L["TOOLTIP_DURABILITY"], string.format("|cff%02x%02x%02x%d%%|r", r*255, g*255, b*255, dur))
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
        GameTooltip:AddLine(L["TOOLTIP_SESSION"], 0, 1, 1)
        
        -- Cabecera con pipe para separar visualmente
        GameTooltip:AddDoubleLine(L["TOOLTIP_HEADER_ITEM"], L["TOOLTIP_HEADER_PRICE"], 0.7, 0.7, 0.7, 0.7, 0.7, 0.7)
        
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
            GameTooltip:AddLine(L["TOOLTIP_NO_DATA"], 0.5, 0.5, 0.5)
        else
            GameTooltip:AddLine(" ")
            -- Totales
            local sVStr = GetCoinTextureString(sVendor)
            local sAHStr = (sAH > 0) and GetCoinTextureString(sAH) or "N/A"
            GameTooltip:AddDoubleLine("|cff00ff00"..L["TOOLTIP_TOTAL_SESSION"].." ("..sUnits.."u)|r", sVStr .. " | " .. sAHStr)
            
            local bVStr = GetCoinTextureString(bVendor)
            local bAHStr = (bAH > 0) and GetCoinTextureString(bAH) or "N/A"
            GameTooltip:AddDoubleLine("|cff00ffff"..L["TOOLTIP_TOTAL_BAG"].." ("..bUnits.."u)|r", bVStr .. " | " .. bAHStr)
        end
    end
    
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["LEFT_CLICK_HINT"])
    GameTooltip:AddLine(L["SHIFT_CLICK_HINT"])
    GameTooltip:AddLine(L["MOUSE_WHEEL_HINT"])
    GameTooltip:AddLine(L["RIGHT_CLICK_HINT"])
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
        print(string.format("|cff00ff00GatherTracker:|r " .. L["CHAT_GREYS_SOLD"], count, GetCoinTextureString(money)))
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
    
    -- Notificar a AceConfigRegistry si es necesario
    -- LibStub("AceConfigRegistry-3.0"):NotifyChange("GatherTracker")
end

-- v1.7.1 Reset Logic
function GatherTracker:ResetDatabase()
    self.db.global.history = { totalItems = 0, items = {}, achievements = {}, totalValue = 0 }
    print("|cff00ff00[GatherTracker]|r " .. L["CHAT_DB_RESET"])
    
    -- Actualización inmediata (Sin necesidad de reload)
    self:UpdateHistoryUI()
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

function GatherTracker:GetAnnounceGuild() return self.db.profile.announceGuild end
function GatherTracker:SetAnnounceGuild(info, val) self.db.profile.announceGuild = val end

function GatherTracker:ChatCommand(input)
    local command = input and input:trim()
    if not command or command == "" then
        self:ToggleTracking()
    elseif command == "opt" or command == "options" then
        LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
    elseif command == "history" or command == "logros" then
        self:CreateHistoryUI()
    elseif command == "resetdb" then
        -- Redirigir al flujo seguro
        StaticPopup_Show("GT_RESET_CONFIRM")
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
    print('|cff00ff00GatherTracker:|r ' .. L["CHAT_STARTED"] .. ' ' .. self:GetCastInterval() .. 's');
    self.trackingTimer = self:ScheduleRepeatingTimer('TimerFeedback', self:GetCastInterval())
    self.IS_RUNNING = true
    self:UpdateGUI()
end

function GatherTracker:StopTimer()
    print('|cff00ff00GatherTracker:|r ' .. L["CHAT_STOPPED"]);
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
