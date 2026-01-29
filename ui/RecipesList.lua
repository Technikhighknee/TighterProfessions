---------------------------------------------------------------------------
-- ui/RecipesList.lua -- Recipe list with search, filters, and favourites
---------------------------------------------------------------------------
local _, ns = ...
ns.RecipesList = {}
local RL = ns.RecipesList

local ROW_H       = ns.ROW_H or 20
local CONTENT_PAD = 4

RL.filteredRecipes = {}
RL.selectedKey     = nil
RL.visibleRows     = 1
RL.collapsed       = {}  -- Track collapsed state: { ["prof:ProfName"] = true, ["cat:ProfName:CatName"] = true }

---------------------------------------------------------------------------
-- Create
---------------------------------------------------------------------------
function RL:Create(parent)
    local P = ns.PADDING
    local L = ns.L  -- Use dynamic locale

    self.parent = parent
    self.hasAuctionator = Auctionator and Auctionator.API
        and Auctionator.API.v1 and true or false

    -- Top bar: search + filter checkboxes -----------------------------------
    local topBar = CreateFrame("Frame", nil, parent)
    topBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 64, -24)
    topBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -(P + 4), -24)
    topBar:SetHeight(44)

    -- Search box
    local sb = CreateFrame("EditBox", "TPSearchBox", topBar, "InputBoxTemplate")
    sb:SetHeight(22)
    sb:SetPoint("TOPLEFT", topBar, "TOPLEFT", 0, 0)
    sb:SetPoint("TOPRIGHT", topBar, "TOPRIGHT", 0, 0)
    sb:SetAutoFocus(false)
    sb:SetMaxLetters(60)
    sb:SetScript("OnTextChanged", function() RL:Refresh() end)
    sb:SetScript("OnEscapePressed", function(s) s:SetText(""); s:ClearFocus() end)
    sb:SetScript("OnEnterPressed",  function(s) s:ClearFocus() end)
    self.searchBox = sb

    -- Placeholder text
    local ph = sb:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    ph:SetPoint("LEFT", 6, 0)
    ph:SetText(L["SEARCH_PLACEHOLDER"])
    local wasMouseDown = false
    sb:SetScript("OnEditFocusGained", function()
        ph:Hide()
        -- While focused, watch for mouse clicks outside the search box
        -- Exception: shift-click is used to insert item links, so allow it
        sb:SetScript("OnUpdate", function()
            local down = IsMouseButtonDown("LeftButton")
                      or IsMouseButtonDown("RightButton")
            if down and not wasMouseDown and not MouseIsOver(sb) then
                if not IsShiftKeyDown() then
                    sb:ClearFocus()
                end
            end
            wasMouseDown = down
        end)
    end)
    sb:SetScript("OnEditFocusLost", function()
        if sb:GetText() == "" then ph:Show() end
        sb:SetScript("OnUpdate", nil)
        wasMouseDown = false
    end)

    -- Filter checkboxes (below search) --------------------------------------
    local function makeCheck(checkParent, name, label, xOff)
        local cb = CreateFrame("CheckButton", name, checkParent,
            "UICheckButtonTemplate")
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", sb, "BOTTOMLEFT", xOff, 2)
        cb:SetScript("OnClick", function() RL:Refresh() end)
        local txt = _G[name .. "Text"]
        if txt then
            txt:SetText(label)
            txt:SetFontObject("GameFontNormalSmall")
        end
        return cb
    end

    self.cbCraftable  = makeCheck(topBar, "TPFilterCraftable",  L["FILTER_CRAFTABLE"], 0)
    self.cbExperience = makeCheck(topBar, "TPFilterExperience", L["FILTER_XP_GAIN"],  90)
    if self.hasAuctionator then
        self.cbProfit = makeCheck(topBar, "TPFilterProfit", L["FILTER_PROFIT"], 170)
    end

    -- List panel (InsetFrameTemplate) ----------------------------------------
    local listPanel = CreateFrame("Frame", nil, parent, "InsetFrameTemplate")
    listPanel:SetPoint("TOPLEFT", parent, "TOPLEFT", P, -(24 + 44))
    listPanel:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT",
        -P, P + ns.DETAIL_H)
    self.listPanel = listPanel

    -- Scroll frame -----------------------------------------------------------
    local sf = CreateFrame("ScrollFrame", "TPRecipeScroll", listPanel,
        "FauxScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", listPanel, "TOPLEFT", CONTENT_PAD, -CONTENT_PAD)
    sf:SetPoint("BOTTOMRIGHT", listPanel, "BOTTOMRIGHT",
        -(ns.SCROLLBAR_W + CONTENT_PAD), CONTENT_PAD)
    sf:SetScript("OnVerticalScroll", function(s, offset)
        FauxScrollFrame_OnVerticalScroll(s, offset, ROW_H,
            function() RL:UpdateRows() end)
    end)
    self.scrollFrame = sf

    -- Create initial rows ---------------------------------------------------
    self.rows = {}
    self:UpdateVisibleRows()
end

---------------------------------------------------------------------------
-- Dynamic visible-row count
---------------------------------------------------------------------------
function RL:UpdateVisibleRows()
    if not self.listPanel then return end
    local listH   = self.listPanel:GetHeight() - CONTENT_PAD * 2
    local newCount = math.max(1, math.floor(listH / ROW_H))

    if newCount == self.visibleRows and #self.rows >= newCount then return end
    self.visibleRows = newCount

    while #self.rows < newCount do
        local i   = #self.rows + 1
        local row = self:CreateRow(self.listPanel, i)
        if i == 1 then
            row:SetPoint("TOPLEFT", self.listPanel, "TOPLEFT",
                CONTENT_PAD, -CONTENT_PAD)
        else
            row:SetPoint("TOPLEFT", self.rows[i - 1], "BOTTOMLEFT")
        end
        row:SetPoint("RIGHT", self.listPanel, "RIGHT",
            -(ns.SCROLLBAR_W + CONTENT_PAD), 0)
        self.rows[i] = row
    end

    for i = newCount + 1, #self.rows do
        self.rows[i]:Hide()
    end
end

---------------------------------------------------------------------------
-- Row factory
---------------------------------------------------------------------------
function RL:CreateRow(parent, index)
    local C   = ns.Colors
    local row = CreateFrame("Button", nil, parent)
    row:SetHeight(ROW_H)
    row:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Hover highlight
    local hl = row:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    ns.Format:SetSolidTexture(hl,
        C.rowHighlight[1], C.rowHighlight[2],
        C.rowHighlight[3], C.rowHighlight[4])

    -- Selection highlight
    local sel = row:CreateTexture(nil, "BACKGROUND")
    sel:SetAllPoints()
    ns.Format:SetSolidTexture(sel,
        C.rowSelected[1], C.rowSelected[2],
        C.rowSelected[3], C.rowSelected[4])
    sel:Hide()
    row.selTex = sel

    -- Recipe name (difficulty-coloured, full width)
    local name = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    name:SetPoint("LEFT", row, "LEFT", 4, 0)
    name:SetPoint("RIGHT", row, "RIGHT", -4, 0)
    name:SetJustifyH("LEFT")
    name:SetWordWrap(false)
    name:SetNonSpaceWrap(false)
    row.nameText = name

    -- Tooltip on hover (only for recipes, not headers)
    row:SetScript("OnEnter", function(self)
        if self.recipe and self.recipe.resultItemLink then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(self.recipe.resultItemLink)
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Left-click to select/toggle, shift-click to link, right-click to toggle favorite
    row:SetScript("OnClick", function(self, button)
        -- Header rows: toggle collapse on click
        if self.collapseKey then
            if button == "LeftButton" then
                RL.collapsed[self.collapseKey] = not RL.collapsed[self.collapseKey]
                RL:Refresh()
            end
            return
        end

        -- Recipe rows
        if not self.recipeKey then return end

        if button == "RightButton" then
            if ns.db and ns.db.char then
                local favs = ns.db.char.favorites
                favs[self.recipeKey] = not favs[self.recipeKey] or nil
                RL:Refresh()
            end
            return
        end
        if IsShiftKeyDown() and self.recipe and self.recipe.resultItemLink then
            if ChatEdit_InsertLink then
                ChatEdit_InsertLink(self.recipe.resultItemLink)
            end
            return
        end
        RL.selectedKey = self.recipeKey
        RL:UpdateRows()
        ns.RecipeView:SetRecipe(self.recipe)
    end)

    row:Hide()
    return row
end

---------------------------------------------------------------------------
-- Build display list with headers (respects collapsed state)
---------------------------------------------------------------------------
local function buildDisplayList(recipes, collapsed)
    local display = {}
    local lastProf = nil
    local lastCat  = nil
    local profCollapsed = false
    local catCollapsed  = false

    for _, r in ipairs(recipes) do
        -- Insert profession header when profession changes
        if r.profession ~= lastProf then
            local profKey = "prof:" .. r.profession
            profCollapsed = collapsed[profKey] or false

            display[#display + 1] = {
                isHeader    = true,
                headerType  = "profession",
                text        = r.profession,
                collapseKey = profKey,
                isCollapsed = profCollapsed,
            }
            lastProf = r.profession
            lastCat  = nil  -- Reset category when profession changes
            catCollapsed = false
        end

        -- Skip everything under collapsed profession
        if profCollapsed then
            -- Continue to next recipe
        else
            -- Insert category header when category changes (within same profession)
            if r.category and r.category ~= "" and r.category ~= lastCat then
                local catKey = "cat:" .. r.profession .. ":" .. r.category
                catCollapsed = collapsed[catKey] or false

                display[#display + 1] = {
                    isHeader    = true,
                    headerType  = "category",
                    text        = r.category,
                    collapseKey = catKey,
                    isCollapsed = catCollapsed,
                    profession  = r.profession,
                }
                lastCat = r.category
            end

            -- Insert the recipe (only if category is not collapsed)
            if not catCollapsed then
                display[#display + 1] = r
            end
        end
    end

    return display
end

---------------------------------------------------------------------------
-- Refresh / UpdateRows
---------------------------------------------------------------------------
function RL:Refresh()
    self:UpdateVisibleRows()
    local sorted = ns.Scanner:GetSortedRecipes()
    local text   = self.searchBox and self.searchBox:GetText() or ""
    local craft  = self.cbCraftable  and self.cbCraftable:GetChecked()
    local exp    = self.cbExperience and self.cbExperience:GetChecked()
    local profit = self.cbProfit     and self.cbProfit:GetChecked()

    local filtered = ns.Filters:Apply(sorted, text, craft, exp, profit)
    self.displayList = buildDisplayList(filtered, self.collapsed)
    self:UpdateRows()
end

function RL:UpdateRows()
    local data    = self.displayList or {}
    local visRows = self.visibleRows or 1
    FauxScrollFrame_Update(self.scrollFrame, #data, visRows, ROW_H)
    local offset = FauxScrollFrame_GetOffset(self.scrollFrame)

    for i = 1, visRows do
        local row = self.rows[i]
        if not row then break end
        local idx = offset + i

        if idx <= #data then
            local entry = data[idx]

            if entry.isHeader then
                -- Render as header row
                row.recipeKey   = nil
                row.recipe      = nil
                row.collapseKey = entry.collapseKey
                row.selTex:Hide()

                local prefix = entry.isCollapsed and "+ " or "- "

                if entry.headerType == "profession" then
                    -- Profession header: white text
                    row.nameText:SetText(prefix .. entry.text)
                    row.nameText:SetTextColor(1, 1, 1)  -- White
                    row.nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
                else
                    -- Category header: gold/yellow, indented
                    row.nameText:SetText("  " .. prefix .. entry.text)
                    row.nameText:SetTextColor(1, 0.82, 0)  -- Gold
                    row.nameText:SetPoint("LEFT", row, "LEFT", 4, 0)
                end

                row:Show()
            else
                -- Render as recipe row
                local r = entry
                row.recipeKey   = r.key
                row.recipe      = r
                row.collapseKey = nil

                -- Name (coloured by difficulty, star prefix for favorites)
                local dr, dg, db = ns.Format:DifficultyColor(r.skillType)
                local displayName = r.name or "?"
                if r.numMade and r.numMade > 1 then
                    displayName = displayName .. " x" .. r.numMade
                end
                local canCraft = r.canCraftCount or ns.Inventory:CanCraftCount(r)
                if canCraft > 0 then
                    displayName = displayName .. " (" .. canCraft .. ")"
                end
                local favs = ns.db and ns.db.char and ns.db.char.favorites
                if favs and favs[r.key] then
                    displayName = "|cffffd100*|r " .. displayName
                end
                -- Indent recipes under categories
                row.nameText:SetText("    " .. displayName)
                row.nameText:SetTextColor(dr, dg, db)
                row.nameText:SetPoint("LEFT", row, "LEFT", 4, 0)

                -- Selection highlight
                row.selTex:SetShown(self.selectedKey == r.key)

                row:Show()
            end
        else
            row.recipeKey   = nil
            row.collapseKey = nil
            row.recipe    = nil
            row:Hide()
        end
    end
end
