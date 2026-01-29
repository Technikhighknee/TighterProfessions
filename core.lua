---------------------------------------------------------------------------
-- core.lua -- Addon bootstrap, AceDB, events, main frame, slash commands
---------------------------------------------------------------------------
local addonName, ns = ...

---------------------------------------------------------------------------
-- Guard: Ace3 required
---------------------------------------------------------------------------
if not LibStub then
    print("|cffff0000TighterProfessions:|r LibStub is missing. "
        .. "Copy Ace3 libraries into the Libs folder (see README).")
    return
end
local AceAddon = LibStub("AceAddon-3.0", true)
if not AceAddon then
    print("|cffff0000TighterProfessions:|r AceAddon-3.0 not found.")
    return
end

---------------------------------------------------------------------------
-- Localization (using custom locale system from util/Locale.lua)
---------------------------------------------------------------------------
local L = ns.L  -- Already set up in util/Locale.lua with metatable

---------------------------------------------------------------------------
-- Create addon
---------------------------------------------------------------------------
local TP = AceAddon:NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
ns.TP = TP

---------------------------------------------------------------------------
-- Layout constants
---------------------------------------------------------------------------
ns.MAIN_WIDTH  = 336
ns.MAIN_HEIGHT = 424
ns.TITLE_H     = 60
ns.SEARCH_H    = 28
ns.FILTER_H    = 24
ns.HEADER_H    = 18
ns.DETAIL_H    = 215
ns.PADDING     = 8
ns.ROW_H       = 20
ns.SCROLLBAR_W = 20

---------------------------------------------------------------------------
-- Color palette
---------------------------------------------------------------------------
ns.Colors = {
    gold         = { 1, 0.82, 0 },
    rowHighlight = { 1, 1, 1, 0.1 },
    rowSelected  = { 1, 0.82, 0, 0.15 },
    rowStripe    = { 1, 1, 1, 0.05 },
    profitGreen  = { 0.1, 1, 0.1 },
    lossRed      = { 1, 0.1, 0.1 },
    dimText      = { 0.5, 0.5, 0.5 },
}

---------------------------------------------------------------------------
-- AceDB defaults
---------------------------------------------------------------------------
local DB_DEFAULTS = {
    char = {
        favorites = {},
        recipes   = {},
    },
    profile = {
        professionPriority  = {},       -- ordered list of profession names for display order
        language            = nil,      -- nil = use system locale
    },
}

---------------------------------------------------------------------------
-- Options (AceConfig)
---------------------------------------------------------------------------

-- Helper to move profession in priority list
local function moveProfession(index, direction)
    local prio = ns.db.profile.professionPriority
    if not prio then return end
    local newIndex = index + direction
    if newIndex < 1 or newIndex > #prio then return end
    prio[index], prio[newIndex] = prio[newIndex], prio[index]
    if ns.RecipesList then ns.RecipesList:Refresh() end
end

-- Dynamically build profession priority options
local function getProfessionPriorityArgs()
    local args = {
        header = {
            type = "description",
            name = function() return L["OPT_PROF_PRIORITY_DESC"] end,
            order = 0,
        },
    }
    local prio = ns.db and ns.db.profile and ns.db.profile.professionPriority or {}
    for i, profName in ipairs(prio) do
        args["prof" .. i] = {
            type = "group",
            name = i .. ". " .. profName,
            inline = true,
            order = i,
            args = {
                up = {
                    type = "execute",
                    name = "^",
                    desc = "Move up",
                    order = 1,
                    width = 0.3,
                    disabled = (i == 1),
                    func = function() moveProfession(i, -1) end,
                },
                down = {
                    type = "execute",
                    name = "v",
                    desc = "Move down",
                    order = 2,
                    width = 0.3,
                    disabled = (i == #prio),
                    func = function() moveProfession(i, 1) end,
                },
            },
        }
    end
    if #prio == 0 then
        args.noprofs = {
            type = "description",
            name = "|cff888888No professions scanned yet. Open a profession window first.|r",
            order = 1,
        }
    end
    return args
end

local options = {
    name = "TighterProfessions",
    type = "group",
    args = {
        language = {
            type   = "select",
            name   = function() return L["OPT_LANGUAGE"] end,
            desc   = function() return L["OPT_LANGUAGE_DESC"] end,
            values = ns.LanguageNames,
            order  = 1,
            get    = function() return ns.GetSelectedLanguage() end,
            set    = function(_, v)
                ns.db.profile.language = v
                ns.RefreshLocaleUI()
            end,
        },
        profPriorityHeader = {
            type = "header",
            name = function() return L["OPT_PROF_PRIORITY"] end,
            order = 10,
        },
        professionPriority = {
            type = "group",
            name = "",
            inline = true,
            order = 11,
            args = {},  -- Will be populated dynamically
        },
    },
}

-- Update options args dynamically when accessed
local origGetOptions
local function getOptionsTable()
    options.args.professionPriority.args = getProfessionPriorityArgs()
    return options
end

---------------------------------------------------------------------------
-- Lifecycle
---------------------------------------------------------------------------
function TP:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("TighterProfessionsDB", DB_DEFAULTS, true)
    ns.db   = self.db
    if ns.db.char.queue then ns.db.char.queue = nil end

    -- Clean up old profile settings that are no longer used
    if ns.db.profile.sortOrder then ns.db.profile.sortOrder = nil end
    if ns.db.profile.sortAscending ~= nil then ns.db.profile.sortAscending = nil end
    if ns.db.profile.separateProfessions ~= nil then ns.db.profile.separateProfessions = nil end

    -- Initialize profession priority from existing recipes
    ns.Scanner:UpdateProfessionPriority()

    LibStub("AceConfig-3.0"):RegisterOptionsTable("TighterProfessions", getOptionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(
        "TighterProfessions", "TighterProfessions")

    self:RegisterChatCommand("tp",                 "SlashHandler")
    self:RegisterChatCommand("tighterprofessions", "SlashHandler")
end

function TP:OnEnable()
    self:BuildMainFrame()

    self:RegisterEvent("TRADE_SKILL_SHOW",   "OnTradeSkillShow")
    self:RegisterEvent("TRADE_SKILL_UPDATE", "OnTradeSkillUpdate")
    self:RegisterEvent("TRADE_SKILL_CLOSE",  "OnTradeSkillClose")

    if GetNumCrafts then
        self:RegisterEvent("CRAFT_SHOW",   "OnCraftShow")
        self:RegisterEvent("CRAFT_UPDATE", "OnCraftUpdate")
        self:RegisterEvent("CRAFT_CLOSE",  "OnCraftClose")
    end

    self:RegisterEvent("BAG_UPDATE",                   "OnBagUpdate")
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED",     "OnSpellcastSucceeded")
    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED",   "OnSpellcastFailed")
    self:RegisterEvent("UNIT_SPELLCAST_FAILED",        "OnSpellcastFailed")

    self:Print(L["LOADED_MSG"])
end

---------------------------------------------------------------------------
-- Slash command
---------------------------------------------------------------------------
function TP:SlashHandler(input)
    input = strtrim(input or ""):lower()
    if input == "scan" then
        ns.Scanner:ScanTradeSkill()
        ns.Scanner:ScanCraft()
        self:Print(L["MANUAL_SCAN"])
    elseif input == "reset" then
        self.mainFrame:ClearAllPoints()
        self.mainFrame:SetPoint("CENTER")
        self:Print(L["WINDOW_RESET"])
    elseif input == "wipe" then
        if ns.db and ns.db.char then wipe(ns.db.char.recipes) end
        self:Print(L["CACHE_CLEARED"])
        ns.RecipesList:Refresh()
    elseif input == "stop" then
        ns.Crafting:Stop()
        self:Print(L["CRAFTING_STOPPED"])
    elseif input == "options" or input == "config" then
        InterfaceOptionsFrame_OpenToCategory("TighterProfessions")
        InterfaceOptionsFrame_OpenToCategory("TighterProfessions")
    else
        self:ToggleWindow()
    end
end

function TP:ToggleWindow()
    if self.mainFrame:IsShown() then
        self.mainFrame:Hide()
    else
        self.mainFrame:Show()
        ns.Inventory:RefreshCounts()
        ns.RecipesList:Refresh()
        ns.RecipeView:Refresh()
    end
end

---------------------------------------------------------------------------
-- Event handlers
---------------------------------------------------------------------------
function TP:OnTradeSkillShow()
    ns.Scanner:ScanTradeSkill()
    ns.Crafting:TryExecutePending()
end

function TP:OnTradeSkillUpdate()
    if ns.Scanner.isTradeSkillOpen then ns.Scanner:ScanTradeSkill() end
    ns.Crafting:TryExecutePending()
end

function TP:OnTradeSkillClose()
    ns.Scanner:OnTradeSkillClose()
    ns.Crafting:Stop()
end

function TP:OnCraftShow()
    ns.Scanner:ScanCraft()
    ns.Crafting:TryExecutePending()
end

function TP:OnCraftUpdate()
    if ns.Scanner.isCraftOpen then ns.Scanner:ScanCraft() end
    ns.Crafting:TryExecutePending()
end

function TP:OnCraftClose()
    ns.Scanner:OnCraftClose()
    ns.Crafting:Stop()
end

local _bagThrottle = 0
function TP:OnBagUpdate()
    local now = GetTime()
    if now - _bagThrottle < 0.5 then return end
    _bagThrottle = now
    if self.mainFrame and self.mainFrame:IsShown() then
        ns.Inventory:RefreshCounts()
        ns.RecipesList:Refresh()
        ns.RecipeView:Refresh()
    end
end

function TP:OnSpellcastSucceeded(_, unit)
    if unit ~= "player" then return end
    -- Only decrement for TradeSkill batches (DoCraft loop manages its own count)
    if ns.Crafting.remainingAmount > 0 and not ns.Crafting.isActive then
        ns.Crafting:OnCraftCompleted()
    end
    C_Timer.After(0.3, function()
        if self.mainFrame and self.mainFrame:IsShown() then
            ns.Inventory:RefreshCounts()
            ns.RecipesList:Refresh()
            ns.RecipeView:Refresh()
        end
    end)
end

function TP:OnSpellcastFailed(_, unit)
    if unit ~= "player" then return end
    -- TradeSkill batch was interrupted (player moved, etc.) — reset counter
    if ns.Crafting.remainingAmount > 0 and not ns.Crafting.isActive then
        ns.Crafting.remainingAmount = 0
        ns.Crafting:UpdateAmountBox()
    end
end

---------------------------------------------------------------------------
-- Main frame
---------------------------------------------------------------------------
function TP:BuildMainFrame()
    local f = CreateFrame("Frame", "TighterProfessionsFrame", UIParent,
        "ButtonFrameTemplate")
    f:SetSize(ns.MAIN_WIDTH, ns.MAIN_HEIGHT)
    f:SetPoint("CENTER")
    f:SetFrameStrata("MEDIUM")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    f:SetToplevel(true)

    tinsert(UISpecialFrames, "TighterProfessionsFrame")

    local portrait = _G["TighterProfessionsFramePortrait"]
    if portrait then
        portrait:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
    end
    self.portrait = portrait

    local titleText = _G["TighterProfessionsFrameTitleText"]
    if titleText then titleText:SetText(L["TITLE"]) end

    local builtinInset = _G["TighterProfessionsFrameInset"]
    if builtinInset then builtinInset:Hide() end

    f:Hide()
    self.mainFrame = f

    ns.RecipesList:Create(f)
    ns.RecipeView:Create(f)
    ns.Links:HookShiftClick(ns.RecipesList.searchBox)
end
