local GatherTracker = LibStub("AceAddon-3.0"):GetAddon("GatherTracker")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherTracker")

function GatherTracker:ToggleStatsUI()
    if not self.statsFrame then
        self:CreateStatsUI()
    end
    if self.statsFrame:IsShown() then
        self.statsFrame:Hide()
        if self.statsTimer then
            self:CancelTimer(self.statsTimer)
            self.statsTimer = nil
        end
    else
        self.statsFrame:Show()
        self:UpdateStatsUI()
        self.statsTimer = self:ScheduleRepeatingTimer("UpdateStatsTimer", 1)
    end
end

function GatherTracker:UpdateStatsTimer()
    if not self.statsFrame or not self.statsFrame:IsShown() then return end
    if self.statsFrame.activeTab == 1 and self.db.profile.currentSession.isActive and not self.db.profile.currentSession.paused then
        self:UpdateStatsUI()
    end
end

function GatherTracker:CreateStatsUI()
    if self.statsFrame then return end

    local f = CreateFrame("Frame", "GatherTrackerStatsFrame", UIParent, "BackdropTemplate")
    f:SetSize(460, 420)
    local pos = self.db.profile.statsFramePos
    if pos then
        f:ClearAllPoints()
        f:SetPoint(pos.point, UIParent, pos.point, pos.x, pos.y)
    else
        f:SetPoint("CENTER")
    end
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetClampedToScreen(true)
    
    f:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    f:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

    f:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local left, top = self:GetLeft(), self:GetTop()
        if left and top then
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
            GatherTracker.db.profile.statsFramePos = { point = "TOPLEFT", x = left, y = top - (UIParent:GetHeight() or 0) }
        else
            local point, _, _, xOfs, yOfs = self:GetPoint()
            GatherTracker.db.profile.statsFramePos = { point = point, x = xOfs, y = yOfs }
        end
    end)
    
    -- Cabecera
    f.header = CreateFrame("Frame", nil, f)
    f.header:SetPoint("TOPLEFT", 5, -5)
    f.header:SetPoint("TOPRIGHT", -5, -5)
    f.header:SetHeight(25)
    
    f.header.title = f.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.header.title:SetPoint("LEFT", 8, 0)
    f.header.title:SetText(L["STATS_TITLE"] or "Estadísticas de Farmeo")
    
    local btnClose = CreateFrame("Button", nil, f.header, "UIPanelCloseButton")
    btnClose:SetSize(22, 22)
    btnClose:SetPoint("RIGHT", 0, 0)
    btnClose:SetScript("OnClick", function() GatherTracker:ToggleStatsUI() end)
    f.btnClose = btnClose

    -- Botón de Restaurar Posición
    local btnResetPos = CreateFrame("Button", nil, f.header)
    btnResetPos:SetSize(18, 18)
    btnResetPos:SetPoint("RIGHT", btnClose, "LEFT", -2, 0)
    btnResetPos:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
    btnResetPos:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    btnResetPos:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:AddLine(L["RESET_POS_TITLE"] or "Restaurar Posición", 1, 1, 1)
        GameTooltip:AddLine(L["RESET_POS_DESC"] or "Restablece la posición de la ventana de estadísticas al centro de la pantalla.", 0.8, 0.8, 0.8, true)
        GameTooltip:Show()
    end)
    btnResetPos:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    btnResetPos:SetScript("OnClick", function()
        GatherTracker.db.profile.statsFramePos = nil
        f:ClearAllPoints()
        f:SetPoint("CENTER")
        GatherTracker:Print(L["STATS_POS_RESET_MSG"] or "|cff00ff00[GatherTracker]|r Posición de la ventana de estadísticas restaurada al centro.")
    end)
    f.btnResetPos = btnResetPos

    
    -- Separador superior
    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(0.3, 0.3, 0.3, 0.5)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 8, -32)
    line:SetPoint("TOPRIGHT", -8, -32)
    
    -- SCROLL FRAME
    local sf = CreateFrame("ScrollFrame", "GTStatsScrollFrame", f, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 10, -38)
    sf:SetPoint("BOTTOMRIGHT", -28, 45) -- Espacio para pestañas abajo
    
    local content = CreateFrame("Frame", nil, sf)
    content:SetSize(420, 100)
    sf:SetScrollChild(content)
    f.content = content
    f.scrollFrame = sf
    
    f.activeTab = 1
    f.itemRows = {}
    f.historyRows = {}
    
    -- Botones de Pestaña (Tabs)
    local tab1 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    tab1:SetSize(125, 22)
    tab1:SetPoint("BOTTOMLEFT", 15, 12)
    tab1:SetText(L["TAB_ACTIVE_SESSION"] or "Sesión Activa")
    tab1:SetScript("OnClick", function() f.activeTab = 1; GatherTracker:UpdateStatsUI() end)
    f.tab1 = tab1
    
    local tab2 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    tab2:SetSize(125, 22)
    tab2:SetPoint("LEFT", tab1, "RIGHT", 5, 0)
    tab2:SetText(L["TAB_HISTORY"] or "Historial")
    tab2:SetScript("OnClick", function() f.activeTab = 2; GatherTracker:UpdateStatsUI() end)
    f.tab2 = tab2
    
    local tab3 = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    tab3:SetSize(125, 22)
    tab3:SetPoint("LEFT", tab2, "RIGHT", 5, 0)
    tab3:SetText(L["TAB_STATS"] or "Estadísticas")
    tab3:SetScript("OnClick", function() f.activeTab = 3; GatherTracker:UpdateStatsUI() end)
    f.tab3 = tab3
    
    self.statsFrame = f
end

function GatherTracker:UpdateStatsUI()
    if not self.statsFrame or not self.statsFrame:IsShown() then return end
    
    local f = self.statsFrame
    local content = f.content
    local width = content:GetWidth()
    local yOffset = 0
    
    -- Ocultar elementos dinámicos previos
    for _, row in pairs(f.itemRows) do row:Hide() end
    for _, row in pairs(f.historyRows) do row:Hide() end
    if f.inactivePanel then f.inactivePanel:Hide() end
    if f.sessionStatsHeader then f.sessionStatsHeader:Hide() end
    if f.statsPanel then f.statsPanel:Hide() end
    if f.historyHeader then f.historyHeader:Hide() end
    
    -- Sincronizar estado de botones de pestañas
    f.tab1:Enable()
    f.tab2:Enable()
    f.tab3:Enable()
    if f.activeTab == 1 then f.tab1:Disable()
    elseif f.activeTab == 2 then f.tab2:Disable()
    elseif f.activeTab == 3 then f.tab3:Disable() end
    
    local session = self.db.profile.currentSession
    
    ---------------------------------------------------------------------------
    -- PESTAÑA 1: SESIÓN ACTIVA
    ---------------------------------------------------------------------------
    if f.activeTab == 1 then
        if not session.isActive then
            -- Mostrar Panel Inactivo
            if not f.inactivePanel then
                local p = CreateFrame("Frame", nil, content)
                p:SetSize(width, 250)
                p:SetPoint("TOPLEFT", 0, 0)
                
                local txt = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                txt:SetPoint("CENTER", 0, 20)
                txt:SetText(L["SESSION_STATUS_INACTIVE"] or "No hay ninguna sesión activa en este momento.")
                p.text = txt
                
                local btn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
                btn:SetSize(160, 26)
                btn:SetPoint("TOP", txt, "BOTTOM", 0, -15)
                btn:SetText(L["BTN_START_SESSION"] or "Iniciar Sesión")
                btn:SetScript("OnClick", function() GatherTracker:StartFarmingSession() end)
                p.btnStart = btn
                
                f.inactivePanel = p
            end
            f.inactivePanel:Show()
            content:SetHeight(200)
            return
        end
        
        -- Sesión Activa
        if not f.sessionStatsHeader then
            local p = CreateFrame("Frame", nil, content)
            p:SetSize(width, 75)
            p:SetPoint("TOPLEFT", 0, 0)
            
            local zone = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            zone:SetPoint("TOPLEFT", 10, -5)
            p.zone = zone
            
            local timer = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            timer:SetPoint("LEFT", zone, "RIGHT", 15, 0)
            p.timer = timer
            
            local rate = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            rate:SetPoint("TOPLEFT", 10, -28)
            p.rate = rate
            
            -- Línea de valorización de oro acumulado en la sesión
            local goldRate = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            goldRate:SetPoint("TOPLEFT", 10, -44)
            p.goldRate = goldRate
            
            -- Botones de control
            local btnPause = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
            btnPause:SetSize(75, 20)
            btnPause:SetPoint("TOPRIGHT", -10, -5)
            btnPause:SetScript("OnClick", function()
                local s = GatherTracker.db.profile.currentSession
                if s.paused then GatherTracker:ResumeFarmingSession() else GatherTracker:PauseFarmingSession() end
            end)
            p.btnPause = btnPause
            
            local btnStop = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
            btnStop:SetSize(75, 20)
            btnStop:SetPoint("TOPRIGHT", btnPause, "BOTTOMRIGHT", 0, -3)
            btnStop:SetText(L["BTN_STOP_SESSION"] or "Guardar")
            btnStop:SetScript("OnClick", function() GatherTracker:StopFarmingSession(true) end)
            p.btnStop = btnStop
            
            local btnDiscard = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
            btnDiscard:SetSize(75, 20)
            btnDiscard:SetPoint("RIGHT", btnPause, "LEFT", -4, 0)
            btnDiscard:SetText(L["BTN_DISCARD_SESSION"] or "Descartar")
            btnDiscard:SetScript("OnClick", function() GatherTracker:StopFarmingSession(false) end)
            p.btnDiscard = btnDiscard
            
            f.sessionStatsHeader = p
        end
        
        f.sessionStatsHeader:Show()
        
        -- Actualizar datos del Header
        local p = f.sessionStatsHeader
        p.zone:SetText(session.zone)
        
        -- Calcular duración transcurrida
        local rawDuration = time() - session.startTime
        local pauseTime = 0
        if session.paused then
            pauseTime = time() - (session.pauseStartTime or time())
        end
        local totalPause = (session.pauseDuration or 0) + pauseTime
        local activeDuration = rawDuration - totalPause
        if activeDuration < 0 then activeDuration = 0 end
        
        local hh = math.floor(activeDuration / 3600)
        local mm = math.floor((activeDuration % 3600) / 60)
        local ss = activeDuration % 60
        local timeString = string.format("%02d:%02d:%02d", hh, mm, ss)
        if session.paused then
            timeString = timeString .. " (" .. (L["SESSION_STATUS_PAUSED"] or "Pausado") .. ")"
            p.timer:SetTextColor(1, 0.3, 0.3)
            p.btnPause:SetText(L["BTN_RESUME_SESSION"] or "Reanudar")
        else
            p.timer:SetTextColor(1, 1, 1)
            p.btnPause:SetText(L["BTN_PAUSE_SESSION"] or "Pausar")
        end
        p.timer:SetText(timeString)
        
        -- Calcular rendimiento global
        local ratePerHour = 0
        if activeDuration > 0 then
            ratePerHour = (session.totalItems / activeDuration) * 3600
        end
        p.rate:SetText(string.format("%s: |cffFFFFFF%d|r (%s: |cff00ff00%.1f %s|r)", 
            L["STATS_TOTAL_ITEMS"] or "Items", session.totalItems,
            L["SESSION_YIELD_RATE"] or "Tasa", ratePerHour, L["SESSION_ITEMS_H"] or "u/h"))
        
        -- Calcular valor total acumulado de subasta en tiempo real
        local totalValue = 0
        for itemID, qty in pairs(session.items) do
            local _, link = GetItemInfo(itemID)
            local price = self:GetAuctionPrice(link or itemID) or 0
            totalValue = totalValue + (price * qty)
        end
        
        local goldPerHour = 0
        if activeDuration > 0 then
            goldPerHour = (totalValue / activeDuration) * 3600
        end
        p.goldRate:SetText(string.format("Valor: %s (Promedio: %s/h)", 
            GetCoinTextureString(totalValue), GetCoinTextureString(goldPerHour)))
        
        yOffset = 75
        
        -- Separador interno
        if not p.line then
            local l = p:CreateTexture(nil, "ARTWORK")
            l:SetColorTexture(0.3, 0.3, 0.3, 0.3)
            l:SetHeight(1)
            l:SetPoint("TOPLEFT", 10, -69)
            l:SetPoint("TOPRIGHT", -10, -69)
            p.line = l
        end
        
        -- Dibujar items recolectados en la sesión
        local sortedItems = {}
        for itemID, qty in pairs(session.items) do
            table.insert(sortedItems, { id = itemID, qty = qty })
        end
        table.sort(sortedItems, function(a, b) return a.qty > b.qty end)
        
        local activeRowIdx = 0
        for _, itemData in ipairs(sortedItems) do
            activeRowIdx = activeRowIdx + 1
            local row = f.itemRows[activeRowIdx]
            if not row then
                row = CreateFrame("Frame", nil, content)
                row:SetSize(width - 20, 22)
                
                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(16, 16)
                row.icon:SetPoint("LEFT", 10, 0)
                
                row.rate = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                row.rate:SetPoint("RIGHT", -10, 0)
                row.rate:SetWidth(50)
                row.rate:SetJustifyH("RIGHT")
                
                -- Columna Nueva de Valor AH
                row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.gold:SetPoint("RIGHT", row.rate, "LEFT", -8, 0)
                row.gold:SetWidth(125)
                row.gold:SetJustifyH("RIGHT")
                
                row.qty = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.qty:SetPoint("RIGHT", row.gold, "LEFT", -8, 0)
                row.qty:SetWidth(45)
                row.qty:SetJustifyH("RIGHT")
                
                row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.name:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)
                row.name:SetPoint("RIGHT", row.qty, "LEFT", -8, 0)
                row.name:SetJustifyH("LEFT")
                row.name:SetWordWrap(false)
                
                f.itemRows[activeRowIdx] = row
            end
            
            row:SetPoint("TOPLEFT", 0, -yOffset)
            row:Show()
            
            local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemData.id)
            if not name then name = "Item " .. itemData.id end
            
            row.icon:SetTexture(icon or GetItemIcon(itemData.id))
            row.name:SetText(name)
            row.qty:SetText("x" .. itemData.qty)
            
            -- Calcular valor de subasta del item en tiempo real
            local price = self:GetAuctionPrice(link or itemData.id) or 0
            local totalItemGold = price * itemData.qty
            row.gold:SetText((totalItemGold > 0) and GetCoinTextureString(totalItemGold) or "|cff808080N/A|r")
            
            local itemRate = 0
            if activeDuration > 0 then
                itemRate = (itemData.qty / activeDuration) * 3600
            end
            row.rate:SetText(string.format("%.1f/h", itemRate))
            
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_NONE")
                GameTooltip_SetDefaultAnchor(GameTooltip, self)
                if link then
                    GameTooltip:SetHyperlink(link)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddDoubleLine("Precio Unitario (AH):", (price > 0) and GetCoinTextureString(price) or "|cff808080N/A|r", 0.7, 0.7, 0.7, 1, 1, 1)
                    GameTooltip:AddDoubleLine("Valor Total (AH):", (totalItemGold > 0) and GetCoinTextureString(totalItemGold) or "|cff808080N/A|r", 0.7, 0.7, 0.7, 1, 1, 1)
                else
                    GameTooltip:AddLine(name)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            yOffset = yOffset + 22
        end
        
        content:SetHeight(yOffset + 10)
        
    ---------------------------------------------------------------------------
    -- PESTAÑA 2: HISTORIAL
    ---------------------------------------------------------------------------
    elseif f.activeTab == 2 then
        local history = self.db.global.sessions or {}
        
        if #history == 0 then
            if not f.inactivePanel then
                f.inactivePanel = CreateFrame("Frame", nil, content)
                f.inactivePanel:SetSize(width, 200)
                f.inactivePanel:SetPoint("TOPLEFT", 0, 0)
                f.inactivePanel.text = f.inactivePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                f.inactivePanel.text:SetPoint("CENTER")
            end
            f.inactivePanel.text:SetText(L["TOOLTIP_NO_DATA"] or "No hay historial guardado.")
            f.inactivePanel:Show()
            content:SetHeight(200)
            return
        end
        
        -- Cabecera con botón de limpiar (v2.12.0)
        if not f.historyHeader then
            local p = CreateFrame("Frame", nil, content)
            p:SetSize(width, 24)
            
            local txt = p:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            txt:SetPoint("LEFT", 5, 0)
            txt:SetText("Sesiones Guardadas")
            p.text = txt
            
            local btn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
            btn:SetSize(80, 18)
            btn:SetPoint("RIGHT", -10, 0)
            btn:SetText(L["BTN_CLEAR_LIST_SHORT"] or "Limpiar")
            btn:SetScript("OnClick", function()
                StaticPopup_Show("GT_CLEAR_HISTORY_CONFIRM")
            end)
            p.btnClear = btn
            
            f.historyHeader = p
        end
        f.historyHeader:SetPoint("TOPLEFT", 0, 0)
        f.historyHeader:Show()
        yOffset = 25
        
        local activeRowIdx = 0
        -- Listar sesiones de más nuevas a más antiguas
        for i = #history, 1, -1 do
            local record = history[i]
            activeRowIdx = activeRowIdx + 1
            local row = f.historyRows[activeRowIdx]
            
            if not row then
                row = CreateFrame("Frame", nil, content)
                row:SetSize(width - 15, 26)
                
                row.bg = row:CreateTexture(nil, "BACKGROUND")
                row.bg:SetAllPoints()
                row.bg:SetColorTexture(1, 1, 1, 0.03)
                
                row.date = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                row.date:SetPoint("LEFT", 5, 0)
                row.date:SetWidth(70) -- Reducido para dar espacio al oro
                row.date:SetJustifyH("LEFT")
                
                row.char = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.char:SetPoint("LEFT", row.date, "RIGHT", 5, 0)
                row.char:SetWidth(60) -- Reducido
                row.char:SetJustifyH("LEFT")
                
                row.yield = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                row.yield:SetPoint("RIGHT", -25, 0)
                row.yield:SetWidth(90)
                row.yield:SetJustifyH("RIGHT")
                
                -- Columna Oro Histórico
                row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.gold:SetPoint("RIGHT", row.yield, "LEFT", -5, 0)
                row.gold:SetWidth(110)
                row.gold:SetJustifyH("RIGHT")
                
                row.zone = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.zone:SetPoint("LEFT", row.char, "RIGHT", 5, 0)
                row.zone:SetPoint("RIGHT", row.gold, "LEFT", -5, 0)
                row.zone:SetJustifyH("LEFT")
                row.zone:SetWordWrap(false)
                
                local del = CreateFrame("Button", nil, row, "UIPanelCloseButton")
                del:SetSize(16, 16)
                del:SetPoint("RIGHT", -2, 0)
                del:SetScript("OnClick", function(s)
                    local parent = s:GetParent()
                    table.remove(GatherTracker.db.global.sessions, parent.historyIndex)
                    GatherTracker:UpdateStatsUI()
                end)
                row.delBtn = del
                
                f.historyRows[activeRowIdx] = row
            end
            
            row:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                GameTooltip:AddLine(date("%d/%m/%Y %H:%M", record.startTime), 1, 0.82, 0)
                GameTooltip:AddDoubleLine("Zona:", record.zone or "Unknown", 0.7, 0.7, 0.7, 1, 1, 1)
                
                local activeSec = record.duration or 1
                local hh = math.floor(activeSec / 3600)
                local mm = math.floor((activeSec % 3600) / 60)
                local ss = activeSec % 60
                GameTooltip:AddDoubleLine("Duración:", string.format("%02d:%02d:%02d", hh, mm, ss), 0.7, 0.7, 0.7, 1, 1, 1)
                
                local goldVal = record.totalValue or 0
                local goldPerHour = (goldVal / activeSec) * 3600
                GameTooltip:AddDoubleLine("Valor Total (AH):", GetCoinTextureString(goldVal), 0.7, 0.7, 0.7, 1, 1, 1)
                GameTooltip:AddDoubleLine("Oro por Hora (AH):", GetCoinTextureString(goldPerHour) .. "/h", 0.7, 0.7, 0.7, 1, 1, 1)
                
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Objetos Recolectados:", 0, 1, 1)
                for itemIDStr, qty in pairs(record.items or {}) do
                    local itemID = tonumber(itemIDStr)
                    local name, link = GetItemInfo(itemID)
                    if not name then name = "Item " .. itemIDStr end
                    
                    local price = GatherTracker:GetAuctionPrice(link or itemID) or 0
                    local itemTotalGold = price * qty
                    
                    local lineRight = "x" .. qty
                    if itemTotalGold > 0 then
                        lineRight = lineRight .. " (" .. GetCoinTextureString(itemTotalGold) .. ")"
                    end
                    GameTooltip:AddDoubleLine(name, lineRight, 1, 1, 1, 1, 1, 1)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function() GameTooltip:Hide() end)
            
            row.historyIndex = i
            row:SetPoint("TOPLEFT", 0, -yOffset)
            row:Show()
            
            -- Alternar color de fondo
            if activeRowIdx % 2 == 0 then
                row.bg:Show()
            else
                row.bg:Hide()
            end
            
            row.date:SetText(date("%d/%m %H:%M", record.startTime))
            
            local cColor = "|cffFFFFFF"
            if record.charClass then
                local classColor = RAID_CLASS_COLORS[record.charClass]
                if classColor then
                    cColor = string.format("|cff%02x%02x%02x", classColor.r*255, classColor.g*255, classColor.b*255)
                end
            end
            row.char:SetText(cColor .. (record.charName or "???") .. "|r")
            row.zone:SetText(record.zone or "Unknown")
            
            local goldVal = record.totalValue or 0
            row.gold:SetText((goldVal > 0) and GetCoinTextureString(goldVal) or "|cff808080N/A|r")
            
            local activeSec = record.duration or 1
            local itemRate = (record.totalItems / activeSec) * 3600
            row.yield:SetText(string.format("%du (|cff00ff00%.1f/h|r)", record.totalItems, itemRate))
            
            yOffset = yOffset + 26
        end
        
        content:SetHeight(yOffset + 10)

    ---------------------------------------------------------------------------
    -- PESTAÑA 3: ESTADÍSTICAS CONSOLIDADAS
    ---------------------------------------------------------------------------
    elseif f.activeTab == 3 then
        local history = self.db.global.sessions or {}
        
        if #history == 0 then
            if not f.inactivePanel then
                f.inactivePanel = CreateFrame("Frame", nil, content)
                f.inactivePanel:SetSize(width, 200)
                f.inactivePanel:SetPoint("TOPLEFT", 0, 0)
                f.inactivePanel.text = f.inactivePanel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                f.inactivePanel.text:SetPoint("CENTER")
            end
            f.inactivePanel.text:SetText(L["TOOLTIP_NO_DATA"] or "No hay historial guardado.")
            f.inactivePanel:Show()
            content:SetHeight(200)
            return
        end
        
        if not f.statsPanel then
            local p = CreateFrame("Frame", nil, content)
            p:SetSize(width, 420)
            p:SetPoint("TOPLEFT", 0, 0)
            
            -- Resumen General
            local titleRes = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            titleRes:SetPoint("TOPLEFT", 10, -5)
            titleRes:SetText("Resumen de Farmeo")
            p.titleRes = titleRes
            
            local timeText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            timeText:SetPoint("TOPLEFT", 10, -25)
            p.timeText = timeText
            
            local itemsText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            itemsText:SetPoint("TOPLEFT", 10, -42)
            p.itemsText = itemsText
            
            local yieldText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            yieldText:SetPoint("TOPLEFT", 10, -59)
            p.yieldText = yieldText
            
            -- Valor en oro total e items/hora consolidado
            local goldText = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
            goldText:SetPoint("TOPLEFT", 10, -76)
            p.goldText = goldText
            
            -- Mejores Mapas
            local titleMaps = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            titleMaps:SetPoint("TOPLEFT", 10, -100) -- Desplazado hacia abajo
            titleMaps:SetText(L["STATS_BEST_ZONES"] or "Mejores Mapas")
            p.titleMaps = titleMaps
            
            p.mapsRows = {}
            for idx = 1, 5 do
                local r = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                r:SetPoint("TOPLEFT", 15, -100 - (idx * 16))
                p.mapsRows[idx] = r
            end
            
            -- Rendimiento por Clase
            local titleClass = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            titleClass:SetPoint("TOPLEFT", 10, -210) -- Desplazado hacia abajo
            titleClass:SetText(L["STATS_CLASS_PERF"] or "Rendimiento por Clase")
            p.titleClass = titleClass
            
            p.classRows = {}
            for idx = 1, 4 do
                local r = p:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                r:SetPoint("TOPLEFT", 15, -210 - (idx * 16))
                p.classRows[idx] = r
            end
            
            -- Mejores Objetos (Top 5) (v2.13.0)
            local titleItems = p:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            titleItems:SetPoint("TOPLEFT", 10, -295)
            titleItems:SetText("Mejores Objetos")
            p.titleItems = titleItems
            
            -- Inicializar estados en f si no existen
            f.itemFilter = f.itemFilter or "ALL"
            f.itemSortMode = f.itemSortMode or "QTY"
            
            -- Crear botones de Filtro de Categoría
            local categories = {
                { key = "ALL", text = "Todo", x = 15 },
                { key = "CAT_MINING", text = "Minería", x = 57 },
                { key = "CAT_HERBALISM", text = "Hierbas", x = 117 },
                { key = "CAT_OTHER", text = "Otros", x = 177 },
            }
            p.catButtons = {}
            for _, cat in ipairs(categories) do
                local btn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
                btn:SetSize(40, 16)
                if cat.key == "CAT_MINING" or cat.key == "CAT_HERBALISM" then
                    btn:SetSize(58, 16)
                elseif cat.key == "CAT_OTHER" then
                    btn:SetSize(46, 16)
                end
                btn:SetPoint("TOPLEFT", cat.x, -315)
                btn:SetText(cat.text)
                btn:SetNormalFontObject("GameFontNormalSmall")
                btn:SetHighlightFontObject("GameFontHighlightSmall")
                btn:SetDisabledFontObject("GameFontDisableSmall")
                btn:SetScript("OnClick", function()
                    f.itemFilter = cat.key
                    GatherTracker:UpdateStatsUI()
                end)
                p.catButtons[cat.key] = btn
            end
            
            -- Crear botones de Ordenación
            local sortModes = {
                { key = "QTY", text = "Cantidad", x = 250 },
                { key = "GOLD", text = "Valor Oro", x = 312 },
            }
            p.sortButtons = {}
            for _, mode in ipairs(sortModes) do
                local btn = CreateFrame("Button", nil, p, "UIPanelButtonTemplate")
                btn:SetSize(60, 16)
                btn:SetPoint("TOPLEFT", mode.x, -315)
                btn:SetText(mode.text)
                btn:SetNormalFontObject("GameFontNormalSmall")
                btn:SetHighlightFontObject("GameFontHighlightSmall")
                btn:SetDisabledFontObject("GameFontDisableSmall")
                btn:SetScript("OnClick", function()
                    f.itemSortMode = mode.key
                    GatherTracker:UpdateStatsUI()
                end)
                p.sortButtons[mode.key] = btn
            end
            
            -- Filas de items (Top 5)
            p.itemRows = {}
            for idx = 1, 5 do
                local row = CreateFrame("Frame", nil, p)
                row:SetSize(width - 30, 20)
                row:SetPoint("TOPLEFT", 15, -317 - (idx * 20))
                
                row.icon = row:CreateTexture(nil, "ARTWORK")
                row.icon:SetSize(14, 14)
                row.icon:SetPoint("LEFT", 5, 0)
                
                row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.name:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
                row.name:SetJustifyH("LEFT")
                row.name:SetWordWrap(false)
                
                row.qty = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.qty:SetPoint("RIGHT", -120, 0)
                row.qty:SetWidth(50)
                row.qty:SetJustifyH("RIGHT")
                
                row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                row.gold:SetPoint("RIGHT", -5, 0)
                row.gold:SetWidth(110)
                row.gold:SetJustifyH("RIGHT")
                
                p.itemRows[idx] = row
            end
            
            f.statsPanel = p
        end
        
        f.statsPanel:Show()
        local p = f.statsPanel
        
        -- Calcular Consolidado General
        local totalDuration = 0
        local totalItems = 0
        local totalGold = 0
        local zoneData = {}
        local classData = {}
        
        for _, record in ipairs(history) do
            local dur = record.duration or 0
            totalDuration = totalDuration + dur
            totalItems = totalItems + (record.totalItems or 0)
            local gold = record.totalValue or 0
            totalGold = totalGold + gold
            
            -- Datos por Zona
            local zoneName = record.zone or "Unknown"
            if not zoneData[zoneName] then
                zoneData[zoneName] = { duration = 0, items = 0, gold = 0 }
            end
            zoneData[zoneName].duration = zoneData[zoneName].duration + dur
            zoneData[zoneName].items = zoneData[zoneName].items + (record.totalItems or 0)
            zoneData[zoneName].gold = zoneData[zoneName].gold + gold
            
            -- Datos por Clase
            local classCode = record.charClass or "Unknown"
            if not classData[classCode] then
                classData[classCode] = { duration = 0, items = 0, gold = 0 }
            end
            classData[classCode].duration = classData[classCode].duration + dur
            classData[classCode].items = classData[classCode].items + (record.totalItems or 0)
            classData[classCode].gold = classData[classCode].gold + gold
        end
        
        -- Formatear tiempo total de farmeo
        local hh = math.floor(totalDuration / 3600)
        local mm = math.floor((totalDuration % 3600) / 60)
        p.timeText:SetText(string.format("%s: |cffFFFFFF%d horas, %d min|r", L["STATS_TOTAL_TIME"] or "Tiempo Total", hh, mm))
        p.itemsText:SetText(string.format("%s: |cffFFFFFF%d objetos|r", L["STATS_TOTAL_ITEMS"] or "Items", totalItems))
        
        local globalRate = 0
        if totalDuration > 0 then
            globalRate = (totalItems / totalDuration) * 3600
        end
        p.yieldText:SetText(string.format("%s: |cff00ff00%.1f %s|r", L["STATS_YIELD_GLOBAL"] or "Rendimiento Promedio", globalRate, L["SESSION_ITEMS_H"] or "u/h"))
        
        local globalGoldRate = 0
        if totalDuration > 0 then
            globalGoldRate = (totalGold / totalDuration) * 3600
        end
        p.goldText:SetText(string.format("Valor Total: %s (Promedio: %s/h)", 
            GetCoinTextureString(totalGold), GetCoinTextureString(globalGoldRate)))
        
        -- Consolidar y ordenar Mejores Zonas
        local sortedZones = {}
        for zoneName, zData in pairs(zoneData) do
            local rate = (zData.duration > 0) and ((zData.items / zData.duration) * 3600) or 0
            local goldRate = (zData.duration > 0) and ((zData.gold / zData.duration) * 3600) or 0
            table.insert(sortedZones, { name = zoneName, rate = rate, goldRate = goldRate, total = zData.items })
        end
        table.sort(sortedZones, function(a, b) return a.rate > b.rate end)
        
        for idx = 1, 5 do
            local textRow = p.mapsRows[idx]
            local zRecord = sortedZones[idx]
            if zRecord then
                textRow:SetText(string.format("%d. %s: |cff00ff00%.1f %s|r (AH: %s/h)", idx, zRecord.name, zRecord.rate, L["SESSION_ITEMS_H"] or "u/h", GetCoinTextureString(zRecord.goldRate)))
                textRow:Show()
            else
                textRow:Hide()
            end
        end
        
        -- Consolidar y ordenar Rendimiento por Clase
        local sortedClasses = {}
        for classCode, cData in pairs(classData) do
            local rate = (cData.duration > 0) and ((cData.items / cData.duration) * 3600) or 0
            local goldRate = (cData.duration > 0) and ((cData.gold / cData.duration) * 3600) or 0
            table.insert(sortedClasses, { code = classCode, rate = rate, goldRate = goldRate, total = cData.items })
        end
        table.sort(sortedClasses, function(a, b) return a.rate > b.rate end)
        
        for idx = 1, 4 do
            local textRow = p.classRows[idx]
            local cRecord = sortedClasses[idx]
            if cRecord then
                local className = cRecord.code
                local classColor = RAID_CLASS_COLORS[cRecord.code]
                local coloredName = className
                if classColor then
                    coloredName = string.format("|cff%02x%02x%02x%s|r", classColor.r*255, classColor.g*255, classColor.b*255, className)
                end
                textRow:SetText(string.format("%d. %s: |cff00ff00%.1f %s|r (AH: %s/h)", idx, coloredName, cRecord.rate, L["SESSION_ITEMS_H"] or "u/h", GetCoinTextureString(cRecord.goldRate)))
                textRow:Show()
            else
                textRow:Hide()
            end
        end
        -- Habilitar/Deshabilitar botones de Categoría según el filtro activo
        for catKey, btn in pairs(p.catButtons) do
            if f.itemFilter == catKey then
                btn:Disable()
            else
                btn:Enable()
            end
        end
        
        -- Habilitar/Deshabilitar botones de Ordenación según el modo activo
        for sortKey, btn in pairs(p.sortButtons) do
            if f.itemSortMode == sortKey then
                btn:Disable()
            else
                btn:Enable()
            end
        end
        
        -- Consolidar Mejores Objetos (Top 5) de por vida
        local itemTotals = {}
        for _, record in ipairs(history) do
            for itemIDStr, qty in pairs(record.items or {}) do
                local itemID = tonumber(itemIDStr) or itemIDStr
                
                -- Verificar categoría
                local cat = self:GetItemCategory(itemID)
                local match = false
                if f.itemFilter == "ALL" then
                    match = true
                elseif f.itemFilter == "CAT_MINING" then
                    match = (cat == "CAT_MINING" or cat == "CAT_TREASURES")
                elseif f.itemFilter == "CAT_HERBALISM" then
                    match = (cat == "CAT_HERBALISM")
                elseif f.itemFilter == "CAT_OTHER" then
                    match = (cat == "CAT_FISHING" or cat == "CAT_GENERAL")
                end
                
                if match then
                    itemTotals[itemID] = (itemTotals[itemID] or 0) + qty
                end
            end
        end
        
        local sortedItems = {}
        for itemID, qty in pairs(itemTotals) do
            local name, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
            if not name then
                local _, _, _, _, iconInstant = GetItemInfoInstant(itemID)
                name = "Item " .. itemID
                icon = iconInstant
            end
            
            -- Obtener precio actual de subasta de hoy
            local priceUnit = self:GetAuctionPrice(link or itemID) or 0
            local goldActual = priceUnit * qty
            
            table.insert(sortedItems, {
                id = itemID,
                name = name,
                link = link,
                qty = qty,
                gold = goldActual,
                icon = icon or GetItemIcon(itemID)
            })
        end
        
        -- Ordenamiento dual
        if f.itemSortMode == "QTY" then
            table.sort(sortedItems, function(a, b) return a.qty > b.qty end)
        else
            table.sort(sortedItems, function(a, b) return a.gold > b.gold end)
        end
        
        -- Pintar el ranking Top 5
        for idx = 1, 5 do
            local row = p.itemRows[idx]
            local iRecord = sortedItems[idx]
            if iRecord then
                row.icon:SetTexture(iRecord.icon)
                row.name:SetText(idx .. ". " .. iRecord.name)
                row.qty:SetText("x" .. iRecord.qty)
                row.gold:SetText((iRecord.gold > 0) and GetCoinTextureString(iRecord.gold) or "|cff808080N/A|r")
                
                -- Tooltip interactivo con ANCHOR_RIGHT sobre f
                local link = iRecord.link
                local name = iRecord.name
                row:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
                    if link then
                        GameTooltip:SetHyperlink(link)
                    else
                        GameTooltip:AddLine(name)
                    end
                    GameTooltip:Show()
                end)
                row:SetScript("OnLeave", function() GameTooltip:Hide() end)
                row:Show()
            else
                row:Hide()
            end
        end
        
        content:SetHeight(510)
    end
end

-- Diálogos emergentes seguros
StaticPopupDialogs["GT_CLEAR_HISTORY_CONFIRM"] = {
    text = L["CONFIRM_CLEAR_HISTORY"] or "¿Estás seguro de que deseas BORRAR todo el historial de sesiones?",
    button1 = L["RESET_BUTTON_YES"] or "Sí, borrar",
    button2 = L["RESET_BUTTON_NO"] or "Cancelar",
    OnAccept = function()
        wipe(GatherTracker.db.global.sessions)
        GatherTracker:UpdateStatsUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}


