local PATTERNS = {
    -- X://Y most urls
    "^(%a[%w+.-]+://%S+)",
    "%f[%S](%a[%w+.-]+://%S+)",
    -- www.X.Y domain
    "^(www%.[-%w_%%]+%.(%a%a+))",
    "%f[%S](www%.[-%w_%%]+%.(%a%a+))",
    -- www.X.Y domain and path
    "^(www%.[-%w_%%]+%.(%a%a+)/%S+)",
    "%f[%S](www%.[-%w_%%]+%.(%a%a+)/%S+)",
    -- ip address
    "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d)%f[%D]",
    "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d)%f[%D]",
    -- ip address with port
    "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
    "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]",
    -- ip address with path
    "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
    "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)",
    -- ip address with port and path
    "^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
    "%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)",
}

local function formatURL(url)
    url = "|cff".."18f24b".."|Hurl:"..url.."|h"..url.."|h|r "
    return url
end

local function makeClickable(self, event, msg, ...)    
    for k,p in pairs(PATTERNS) do
        if string.find(msg, p) then
            msg = string.gsub(msg, p, formatURL("%1"))
            return false, msg, ...
        end
    end
    return false, msg, ...
end

-- Create the URLClickerBox
local URLClickerBox = CreateFrame("Frame", "URLClickerBox", UIParent, "DialogBoxFrame")
URLClickerBox:SetSize(500, 150)
URLClickerBox:SetPoint("CENTER")
URLClickerBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight",
    edgeSize = 16,
    insets = { left = 8, right = 8, top = 8, bottom = 8 },
})
URLClickerBox:SetBackdropBorderColor(0.6, 0.6, 0.6, 0.6);

URLClickerBox:SetMovable(true)
URLClickerBox:EnableMouse(true)
URLClickerBox:RegisterForDrag("LeftButton")
URLClickerBox:SetScript("OnDragStart", URLClickerBox.StartMoving)
URLClickerBox:SetScript("OnDragStop", URLClickerBox.StopMovingOrSizing)

URLClickerBox.text = URLClickerBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
URLClickerBox.text:SetPoint("TOP", 0, -20)
URLClickerBox.text:SetText("CTRL + C to copy the link !")

URLClickerBox.editBox = CreateFrame("EditBox", nil, URLClickerBox, "InputBoxTemplate")
URLClickerBox.editBox:SetSize(450, 50)
URLClickerBox.editBox:SetPoint("CENTER", 0, 0)
URLClickerBox.editBox:SetAutoFocus(true)
URLClickerBox.editBox:SetFontObject(GameFontHighlight)
URLClickerBox.editBox:SetScript("OnEscapePressed", function() URLClickerBox:Hide() end)

local function URLClicker_OnHyperlinkClick(self, link, text, button)
    if string.sub(link, 1, 3) == "url" then
        local url = string.sub(link, 5)
        URLClickerBox:Show()
        URLClickerBox.editBox:SetText(url)
        URLClickerBox.editBox:HighlightText()
    end
end

-- Global handler for all chat hyperlinks
hooksecurefunc("SetItemRef", function(link, text, button, chatFrame)
    if type(link) == "string" and string.sub(link, 1, 3) == "url" then
        local url = string.sub(link, 5)
        URLClickerBox:Show()
        URLClickerBox.editBox:SetText(url)
        URLClickerBox.editBox:HighlightText()
    end
end)


for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame"..i]
    if frame then
        if frame.SetHyperlinksEnabled then
            frame:SetHyperlinksEnabled(true)
        end
        if frame.HookScript then
            frame:HookScript("OnHyperlinkClick", URLClicker_OnHyperlinkClick)
        end
    end
end

local CHAT_TYPES = {
    "SYSTEM",
    "SAY",
    "PARTY",
    "PARTY_LEADER",
    "RAID",
    "RAID_LEADER",
    "RAID_WARNING",
    "GUILD",
    "OFFICER",
    "YELL",
    "WHISPER",
    "WHISPER_INFORM",
    "BN_WHISPER",
    "BN_WHISPER_INFORM",
    "REPLY",
    "EMOTE",
    "TEXT_EMOTE",
    "CHANNEL",
    "CHANNEL_NOTICE",
    "CHANNEL_NOTICE_USER",
    "CHANNEL1",
    "CHANNEL2",
    "CHANNEL3",
    "CHANNEL4",
    "CHANNEL5",
    "CHANNEL6",
    "CHANNEL7",
    "CHANNEL8",
    "CHANNEL9",
    "CHANNEL10",
    "COMMUNITIES_CHANNEL",
    "AFK",
    "DND",
    "FILTERED",
    "BATTLEGROUND",
    "BATTLEGROUND_LEADER",
    "RESTRICTED"
}

for _, chatType in pairs(CHAT_TYPES) do
    ChatFrame_AddMessageEventFilter("CHAT_MSG_" .. chatType, makeClickable)
end
