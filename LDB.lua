local addonName, ns = ...
local GatherTracker = LibStub("AceAddon-3.0"):GetAddon("GatherTracker")
local L = LibStub("AceLocale-3.0"):GetLocale("GatherTracker")

-- DataBroker is optional/copied, so we check if LibDataBroker is loaded
local LDB = LibStub("LibDataBroker-1.1", true)
if not LDB then return end

-- Create the DataBroker Object
local gtLDB = LDB:NewDataObject("GatherTracker", {
    type = "data source",
    text = "GatherTracker",
    icon = "Interface\\Icons\\INV_Misc_Bag_08", -- Default icon (Bag)
    OnClick = function(self, button)
        if button == "RightButton" then
            -- Open Options
            LibStub("AceConfigDialog-3.0"):Open("GatherTracker")
        else
            -- Toggle Tracking (Left Click)
            GatherTracker:ToggleTracking()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("GatherTracker")
        tooltip:AddLine(" ")
        
        -- Status Line
        local status = "|cFF00FF00" .. L["ACTIVE"] .. "|r"
        if not GatherTracker.IS_RUNNING then
            status = "|cFFFF0000" .. L["PAUSED"] .. "|r"
        end
        tooltip:AddDoubleLine(L["STATUS_LABEL"], status)
        
        -- Interval Line
        tooltip:AddDoubleLine(L["INTERVAL_LABEL"], GatherTracker:GetCastInterval() .. "s")
        
        tooltip:AddLine(" ")
        tooltip:AddLine(L["LEFT_CLICK_HINT"])
        tooltip:AddLine(L["RIGHT_CLICK_HINT"])
    end,
})

-- Initialize DBIcon if available (Minimap Button)
local icon = LibStub("LibDBIcon-1.0", true)
if icon then
    GatherTracker.LDBIcon = icon -- Expose to main addon if needed
    
    -- Register icon during OnInitialize or PlayerLogin
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", function()
        if GatherTracker and GatherTracker.db then
             -- Ensure DB table exists
             if not GatherTrackerDBIcon then GatherTrackerDBIcon = {} end
             
             -- Register
             icon:Register("GatherTracker", gtLDB, GatherTrackerDBIcon)
        end
    end)
    f:RegisterEvent("PLAYER_LOGIN")
end

-- Function to update LDB Text/Icon dynamically
function GatherTracker:UpdateLDB()
    if not gtLDB then return end
    
    -- Update Icon based on current state (Mining, Herb, etc) or Pause
    -- Accessing internal state might require exposing some variables in Core
    -- For now, we stick to detailed tooltip and static icon/text or simple updates
    
    -- Example: Update text with current tracking mode?
    -- gtLDB.text = "GT: " .. (CurrentTrackingName or "...")
end
