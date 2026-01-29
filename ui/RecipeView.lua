---------------------------------------------------------------------------
-- ui/RecipeView.lua -- Detail panel: icon, name, cost/profit, reagents,
--                      amount spinner, Craft / Craft All buttons
---------------------------------------------------------------------------
local _, ns = ...
ns.RecipeView = {}
local RV = ns.RecipeView

local MAX_INGREDIENTS = 8
local REAGENT_COLS    = 2
local ICON_SZ         = 37
local SLOT_H          = 42
RV.recipe = nil

---------------------------------------------------------------------------
-- Create
---------------------------------------------------------------------------
function RV:Create(parent)
    local P = ns.PADDING
    local C = ns.Colors
    local L = ns.L  -- Dynamic locale lookup

    -- Detail container -------------------------------------------------------
    local detail = CreateFrame("Frame", "TighterProfessionsDetail", parent,
        "InsetFrameTemplate")
    detail:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", P, P + ns.DETAIL_H)
    detail:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -P, 28)
    self.panel = detail

    -- Result icon (40x40 with slot background) -------------------------------
    local icon = detail:CreateTexture(nil, "ARTWORK")
    icon:SetSize(40, 40)
    icon:SetPoint("TOPLEFT", 8, -8)
    icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    self.icon = icon

    local iconSlot = detail:CreateTexture(nil, "BACKGROUND")
    iconSlot:SetSize(46, 46)
    iconSlot:SetPoint("CENTER", icon, "CENTER", 0, 0)
    iconSlot:SetTexture("Interface\\Buttons\\UI-Quickslot2")

    -- Icon tooltip + shift-click overlay
    local iconBtn = CreateFrame("Button", nil, detail)
    iconBtn:SetAllPoints(icon)
    iconBtn:SetScript("OnEnter", function(self)
        local r = RV.recipe
        if r and r.resultItemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(r.resultItemLink)
            GameTooltip:Show()
        end
    end)
    iconBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    iconBtn:SetScript("OnClick", function()
        local r = RV.recipe
        if IsShiftKeyDown() and r and r.resultItemLink then
            if ChatEdit_InsertLink then
                ChatEdit_InsertLink(r.resultItemLink)
            end
        end
    end)

    -- Recipe name (right of icon) --------------------------------------------
    local nameFS = detail:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameFS:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, -2)
    nameFS:SetPoint("RIGHT", detail, "RIGHT", -8, 0)
    nameFS:SetJustifyH("LEFT")
    nameFS:SetText("No recipe selected")
    nameFS:SetTextColor(1, 1, 1)
    self.nameText = nameFS

    -- Tool requirement (anchored below name) ---------------------------------
    local reqFS = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    reqFS:SetPoint("TOPLEFT", nameFS, "BOTTOMLEFT", 0, -2)
    reqFS:SetJustifyH("LEFT")
    reqFS:SetTextColor(1, 0.8, 0)
    reqFS:SetText("")
    reqFS:Hide()
    self.reqText = reqFS

    -- Cost label (anchored below icon; shifts down when reqText is visible) --
    local costFS = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    costFS:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -6)
    costFS:SetJustifyH("LEFT")
    costFS:SetTextColor(1, 1, 1)
    costFS:Hide()
    self.costText = costFS

    -- Profit label (anchored below cost) -------------------------------------
    local profitFS = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    profitFS:SetPoint("TOPLEFT", costFS, "BOTTOMLEFT", 0, -1)
    profitFS:SetJustifyH("LEFT")
    profitFS:Hide()
    self.profitText = profitFS

    -- Reagents header (anchored dynamically in Refresh) ----------------------
    local ingHdr = detail:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    ingHdr:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -8)
    ingHdr:SetTextColor(C.gold[1], C.gold[2], C.gold[3])
    ingHdr:SetText(L["REAGENTS"])
    self.ingHdr = ingHdr

    -- Reagent slots (2-column grid) ------------------------------------------
    self.ingSlots = {}
    for i = 1, MAX_INGREDIENTS do
        local slot = CreateFrame("Frame", nil, detail)
        slot:SetSize(200, SLOT_H)

        local tex = slot:CreateTexture(nil, "ARTWORK")
        tex:SetSize(ICON_SZ, ICON_SZ)
        tex:SetPoint("TOPLEFT", 0, -2)
        tex:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        slot.icon = tex

        local nameFrame = slot:CreateTexture(nil, "BACKGROUND")
        nameFrame:SetWidth(144)
        nameFrame:SetPoint("TOPLEFT", tex, "TOPRIGHT", -12, 10)
        nameFrame:SetPoint("BOTTOMLEFT", tex, "BOTTOMRIGHT", -12, -10)
        nameFrame:SetTexture("Interface\\QuestFrame\\UI-QuestItemNameFrame")
        slot.nameFrame = nameFrame

        local cnt = slot:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
        cnt:SetPoint("TOPLEFT", tex, "BOTTOMLEFT", 4, 12)
        cnt:SetTextColor(1, 1, 1)
        slot.countText = cnt

        local nm = slot:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        nm:SetPoint("LEFT", tex, "RIGHT", 4, 0)
        nm:SetPoint("RIGHT", slot, "RIGHT", -2, 0)
        nm:SetJustifyH("LEFT")
        nm:SetJustifyV("MIDDLE")
        nm:SetWordWrap(true)
        slot.nameText = nm

        slot:EnableMouse(true)
        slot:SetScript("OnEnter", function(self)
            if self.itemID then
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(self.itemID)
                GameTooltip:Show()
            end
        end)
        slot:SetScript("OnLeave", function() GameTooltip:Hide() end)
        slot:SetScript("OnMouseUp", function(self)
            if IsShiftKeyDown() and self.itemID then
                local _, link = GetItemInfo(self.itemID)
                if link and ChatEdit_InsertLink then
                    ChatEdit_InsertLink(link)
                end
            end
        end)

        slot:Hide()
        self.ingSlots[i] = slot
    end

    self:LayoutReagents()

    -- Button styling helpers -------------------------------------------------
    local function tintButton(btn, r, g, b)
        for _, region in ipairs({btn:GetRegions()}) do
            if region:GetObjectType() == "Texture"
               and region:GetDrawLayer() ~= "HIGHLIGHT" then
                region:SetVertexColor(r, g, b)
            end
        end
    end

    local function styleEnabled(btn)
        tintButton(btn, 0.6, 0.6, 0.6)
        btn:GetFontString():SetTextColor(1, 0.82, 0)
    end

    local function styleDisabled(btn)
        tintButton(btn, 0.3, 0.3, 0.3)
        btn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
    end

    local function styleGold(btn)
        tintButton(btn, 0.75, 0.6, 0.1)
        btn:GetFontString():SetTextColor(1, 0.82, 0)
    end

    -- Store styling functions for later use
    RV.styleEnabled  = styleEnabled
    RV.styleDisabled = styleDisabled

    -- Truncate button text to fit width (like Blizzard's "Alle erst.")
    local function fitButtonText(btn, text, maxWidth)
        local fs = btn:GetFontString()
        fs:SetText(text)
        if fs:GetStringWidth() <= maxWidth then return end
        for i = #text - 1, 1, -1 do
            fs:SetText(text:sub(1, i) .. ".")
            if fs:GetStringWidth() <= maxWidth then return end
        end
        fs:SetText(".")
    end

    -- Controls (button bar at frame bottom) ----------------------------------
    -- 4 equal-width sections: [Craft All] [< Number >] [Craft] [Close]
    local btnY      = 4
    local btnH      = 22
    local innerW    = ns.MAIN_WIDTH - P * 2  -- usable width inside padding
    local quarterW  = math.floor(innerW / 4)
    local amtBox    -- forward ref for closures

    -- Section 1: Craft All button (fills its quarter)
    local craftAllBtn = ns.Crafting:CreateSecureButton(
        "TPCraftAllBtn", parent, nil, quarterW, btnH)
    craftAllBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", P, btnY)
    fitButtonText(craftAllBtn, L["CRAFT_ALL"], quarterW - 8)
    styleDisabled(craftAllBtn)
    craftAllBtn:SetScript("PreClick", function(self)
        if InCombatLockdown() then self._tpReady = false; return end
        local recipe = RV.recipe
        if not recipe then
            self:SetAttribute("type", nil); self._tpReady = false; return
        end
        local cc = ns.Inventory:CanCraftCount(recipe)
        if cc <= 0 then
            self:SetAttribute("type", nil); self._tpReady = false; return
        end
        amtBox:SetText(tostring(cc))
        ns.Crafting:SetupPreClick(self, recipe, cc)
    end)
    craftAllBtn:SetScript("PostClick", function(self)
        ns.Crafting:HandlePostClick(self)
    end)

    -- Section 2: [< Number >] spinner (fits in one quarter)
    local spinnerW  = quarterW
    local arrowW    = 17
    local boxW      = spinnerW - arrowW * 2

    local decBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    decBtn:SetSize(arrowW, btnH)
    decBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", P + quarterW, btnY)
    decBtn:SetText("<")
    styleEnabled(decBtn)
    decBtn:SetScript("OnClick", function()
        local v = tonumber(amtBox:GetText()) or 1
        amtBox:SetText(tostring(math.max(1, v - 1)))
    end)

    amtBox = CreateFrame("EditBox", "TPAmountBox", parent, "InputBoxTemplate")
    amtBox:SetSize(boxW, btnH)
    amtBox:SetPoint("LEFT", decBtn, "RIGHT", 0, 0)
    amtBox:SetAutoFocus(false)
    amtBox:SetNumeric(true)
    amtBox:SetMaxLetters(5)
    amtBox:SetText("1")
    amtBox:SetScript("OnEscapePressed", function(s) s:ClearFocus() end)
    amtBox:SetScript("OnEnterPressed",  function(s) s:ClearFocus() end)
    self.amtBox = amtBox

    local incBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    incBtn:SetSize(arrowW, btnH)
    incBtn:SetPoint("LEFT", amtBox, "RIGHT", 0, 0)
    incBtn:SetText(">")
    styleEnabled(incBtn)
    incBtn:SetScript("OnClick", function()
        local v = tonumber(amtBox:GetText()) or 1
        local maxCraft = RV.recipe and RV.recipe.canCraftCount or 9999
        amtBox:SetText(tostring(math.min(v + 1, math.max(1, maxCraft))))
    end)

    -- Section 3: Craft button (fills its quarter)
    local craftBtn = ns.Crafting:CreateSecureButton(
        "TPCraftBtn", parent, nil, quarterW, btnH)
    craftBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", P + quarterW * 2, btnY)
    fitButtonText(craftBtn, L["CRAFT"], quarterW - 8)
    styleDisabled(craftBtn)
    craftBtn:SetScript("PreClick", function(self)
        local recipe = RV.recipe
        local amount = tonumber(amtBox:GetText()) or 1
        ns.Crafting:SetupPreClick(self, recipe, amount)
    end)
    craftBtn:SetScript("PostClick", function(self)
        ns.Crafting:HandlePostClick(self)
    end)

    self.craftAllBtn = craftAllBtn
    self.craftBtn    = craftBtn
    craftAllBtn:Disable()
    craftBtn:Disable()

    -- Section 4: Close button (fills its quarter, golden)
    local closeBtn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    closeBtn:SetSize(quarterW, btnH)
    closeBtn:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", P + quarterW * 3, btnY)
    fitButtonText(closeBtn, L["CLOSE"], quarterW - 8)
    styleGold(closeBtn)
    closeBtn:SetScript("OnClick", function() parent:Hide() end)
    self.closeBtn = closeBtn

    -- Store fitButtonText for locale refresh
    self.fitButtonText = fitButtonText
    self.styleGold = styleGold
    self.quarterW = quarterW
end

---------------------------------------------------------------------------
-- Reagent grid layout
---------------------------------------------------------------------------
function RV:LayoutReagents()
    if not self.panel then return end
    local availW = self.panel:GetWidth() - 8
    local slotW  = math.max(100, math.floor(availW / REAGENT_COLS))

    for i = 1, MAX_INGREDIENTS do
        local slot = self.ingSlots[i]
        local col  = (i - 1) % REAGENT_COLS
        local row  = math.floor((i - 1) / REAGENT_COLS)
        slot:SetWidth(slotW)
        slot:ClearAllPoints()
        slot:SetPoint("TOPLEFT", self.ingHdr, "BOTTOMLEFT",
            col * slotW, -(row * SLOT_H) - 2)
    end
end

---------------------------------------------------------------------------
-- Set / Refresh
---------------------------------------------------------------------------
function RV:SetRecipe(recipe)
    self.recipe = recipe
    if self.amtBox then
        self.amtBox:SetText("1")
    end
    self:Refresh()
end

function RV:Refresh()
    -- Re-fetch from DB so we never display stale data after a rescan
    if self.recipe and self.recipe.key then
        local all = ns.Scanner:GetAllRecipes()
        if all[self.recipe.key] then
            self.recipe = all[self.recipe.key]
        end
    end

    local r = self.recipe
    local C = ns.Colors

    -- Enable/disable craft buttons based on craftability
    if self.craftAllBtn then
        local canCraft = r and (r.canCraftCount or ns.Inventory:CanCraftCount(r)) > 0
        if canCraft then
            self.craftAllBtn:Enable()
            self.craftBtn:Enable()
            self.styleEnabled(self.craftAllBtn)
            self.styleEnabled(self.craftBtn)
        else
            self.craftAllBtn:Disable()
            self.craftBtn:Disable()
            self.styleDisabled(self.craftAllBtn)
            self.styleDisabled(self.craftBtn)
        end
    end

    if not r then
        self.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        self.nameText:SetText(ns.L["NO_RECIPE_SELECTED"])
        self.nameText:SetTextColor(1, 1, 1)
        self.reqText:SetText(""); self.reqText:Hide()
        self.costText:Hide()
        self.profitText:Hide()
        self.ingHdr:ClearAllPoints()
        self.ingHdr:SetPoint("TOPLEFT", self.icon, "BOTTOMLEFT", 0, -6)
        for i = 1, MAX_INGREDIENTS do
            self.ingSlots[i]:Hide()
        end
        return
    end

    -- Icon & name
    self.icon:SetTexture(r.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    local displayName = r.resultName or r.name or "?"
    if r.numMade and r.numMade > 1 then
        displayName = displayName .. " (x" .. r.numMade .. ")"
    end
    self.nameText:SetText(displayName)
    local dr, dg, db = ns.Format:DifficultyColor(r.skillType)
    self.nameText:SetTextColor(dr, dg, db)

    -- Tool requirement
    if r.toolName and r.toolName ~= "" then
        self.reqText:SetText(ns.L["REQUIRES"]:format(r.toolName))
        self.reqText:Show()
    else
        self.reqText:SetText("")
        self.reqText:Hide()
    end

    -- Cost / Profit  (anchor chain: icon.BL -> cost -> profit)
    local profit, craftCost = ns.GetRecipeProfit(r)
    if craftCost then
        self.costText:SetText(ns.L["COST"]:format(GetCoinTextureString(craftCost)))
        self.costText:ClearAllPoints()
        self.costText:SetPoint("TOPLEFT", self.icon, "BOTTOMLEFT", 0, -6)
        self.costText:Show()

        if profit then
            local sign      = profit >= 0 and "" or "-"
            local absProfit = math.abs(profit)
            self.profitText:SetText(ns.L["PROFIT"]:format(sign
                .. GetCoinTextureString(absProfit)))
            if profit >= 0 then
                self.profitText:SetTextColor(
                    C.profitGreen[1], C.profitGreen[2], C.profitGreen[3])
            else
                self.profitText:SetTextColor(
                    C.lossRed[1], C.lossRed[2], C.lossRed[3])
            end
            self.profitText:Show()
        else
            self.profitText:Hide()
        end
    else
        self.costText:Hide()
        self.profitText:Hide()
    end

    -- Reagents header  (anchor below the lowest visible cost/profit element,
    -- falling back to below the icon when neither is shown)
    self.ingHdr:ClearAllPoints()
    if self.profitText:IsShown() then
        self.ingHdr:SetPoint("TOPLEFT", self.profitText, "BOTTOMLEFT", 0, -4)
    elseif self.costText:IsShown() then
        self.ingHdr:SetPoint("TOPLEFT", self.costText, "BOTTOMLEFT", 0, -4)
    else
        self.ingHdr:SetPoint("TOPLEFT", self.icon, "BOTTOMLEFT", 0, -6)
    end

    -- Reagent slots
    local ings = r.ingredients or {}
    for i = 1, MAX_INGREDIENTS do
        local slot = self.ingSlots[i]
        local ing  = ings[i]
        if ing then
            slot.icon:SetTexture(ing.icon or
                "Interface\\Icons\\INV_Misc_QuestionMark")
            slot.itemID = ing.itemID
            local have = ing.have or ns.Inventory:GetCount(ing.itemID, ing.name)
            local need = ing.count or 1
            slot.countText:SetText(have .. " /" .. need)
            slot.countText:SetTextColor(1, 1, 1)
            slot.nameText:SetText(ing.name or "?")
            if have >= need then
                slot.nameText:SetTextColor(1, 1, 1)
            else
                slot.nameText:SetTextColor(0.5, 0.5, 0.5)
            end
            slot:Show()
        else
            slot.itemID = nil
            slot:Hide()
        end
    end
end

---------------------------------------------------------------------------
-- Locale refresh (called when language changes)
---------------------------------------------------------------------------
function RV:RefreshLocale()
    local L = ns.L
    local qw = self.quarterW or 80

    -- Update button text
    if self.craftAllBtn and self.fitButtonText then
        self.fitButtonText(self.craftAllBtn, L["CRAFT_ALL"], qw - 8)
    end
    if self.craftBtn and self.fitButtonText then
        self.fitButtonText(self.craftBtn, L["CRAFT"], qw - 8)
    end
    if self.closeBtn and self.fitButtonText then
        self.fitButtonText(self.closeBtn, L["CLOSE"], qw - 8)
        if self.styleGold then self.styleGold(self.closeBtn) end
    end

    -- Update reagents header
    if self.ingHdr then
        self.ingHdr:SetText(L["REAGENTS"])
    end

    -- Refresh the recipe display
    self:Refresh()
end
