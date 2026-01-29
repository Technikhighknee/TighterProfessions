---------------------------------------------------------------------------
-- logic/Crafting.lua -- Craft execution via SecureActionButton
--
-- Manages the two-phase craft flow:
--   PreClick  – if the profession window is closed, configure the button
--               as a secure spell cast to open it; otherwise flag as ready.
--   PostClick – if the window was already open, craft immediately.
--               Otherwise store a pending craft that TryExecutePending()
--               will pick up once the window opens.
---------------------------------------------------------------------------
local _, ns = ...
ns.Crafting = {}
local Crafting = ns.Crafting
local L = nil  -- Set on first use

Crafting.pendingCraft    = nil    -- { recipe, amount, time }
Crafting.isActive        = false  -- true while a DoCraft repeat loop is running
Crafting.remainingAmount = 0     -- counts down on each successful craft

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Create a SecureActionButton styled like UIPanelButton.
function Crafting:CreateSecureButton(name, parent, label, width, height)
    local btn = CreateFrame("Button", name, parent,
        "SecureActionButtonTemplate,UIPanelButtonTemplate")
    btn:SetSize(width or 120, height or 25)
    if label then btn:SetText(label) end
    return btn
end

--- Is the correct profession window open for this recipe?
local function isProfOpen(recipe)
    if not recipe then return false end
    if recipe.isCraft then
        return ns.Scanner.isCraftOpen
           and ns.Scanner.currentProfession == recipe.profession
    else
        return ns.Scanner.isTradeSkillOpen
           and ns.Scanner.currentProfession == recipe.profession
    end
end

---------------------------------------------------------------------------
-- PreClick / PostClick
---------------------------------------------------------------------------

--- Configure the button before the hardware click fires.
--- Either opens the profession (secure spell cast) or marks ready to craft.
function Crafting:SetupPreClick(btn, recipe, amount)
    if InCombatLockdown() then
        btn._tpReady = false
        return
    end
    if not recipe or (amount or 0) <= 0 then
        btn:SetAttribute("type", nil)
        btn._tpReady = false
        return
    end

    if isProfOpen(recipe) then
        btn:SetAttribute("type", nil)
        btn._tpReady = true
    else
        btn:SetAttribute("type", "spell")
        btn:SetAttribute("spell", recipe.profession)
        btn._tpReady = false

        local now = GetTime()
        self.pendingCraft = { recipe = recipe, amount = amount, time = now }
        -- Safety timeout: clear stale pending after 6 seconds
        C_Timer.After(6, function()
            if self.pendingCraft and self.pendingCraft.time == now then
                L = L or ns.L
                ns.TP:Print(L["COULD_NOT_OPEN"]:format(recipe.profession))
                self.pendingCraft = nil
            end
        end)
    end

    btn._tpRecipe = recipe
    btn._tpAmount = amount
end

--- After the hardware click, craft if the window was already open.
function Crafting:HandlePostClick(btn)
    if InCombatLockdown() then return false end

    local recipe = btn._tpRecipe
    local amount = btn._tpAmount or 1
    local ready  = btn._tpReady

    btn._tpReady  = nil
    btn._tpRecipe = nil
    btn._tpAmount = nil

    if not recipe then return false end
    if ready then return self:ExecuteNow(recipe, amount) end
    return false   -- pending path will handle it
end

---------------------------------------------------------------------------
-- Execute craft  (the correct window MUST already be open)
---------------------------------------------------------------------------
function Crafting:ExecuteNow(recipe, amount)
    if not recipe then return false end
    L = L or ns.L  -- Grab locale reference
    amount = amount or 1
    self.remainingAmount = amount

    if recipe.isCraft then
        -- Enchanting / Beast Training – DoCraft has no count param
        local idx = ns.Scanner:FindCraftIndex(recipe.name)
        if not idx then
            ns.TP:Print(L["RECIPE_NOT_FOUND_CRAFT"])
            self.remainingAmount = 0
            return false
        end
        if DoCraft then
            self.isActive = true
            local function doNext(remaining)
                if remaining <= 0 or not self.isActive then
                    self.isActive = false
                    self.remainingAmount = 0
                    return
                end
                if not ns.Scanner.isCraftOpen then
                    self.isActive = false
                    self.remainingAmount = 0
                    return
                end
                local i = ns.Scanner:FindCraftIndex(recipe.name)
                if not i then
                    self.isActive = false
                    self.remainingAmount = 0
                    return
                end
                DoCraft(i)
                self.remainingAmount = remaining - 1
                self:UpdateAmountBox()
                if remaining > 1 then
                    C_Timer.After(2.5, function() doNext(remaining - 1) end)
                else
                    self.isActive = false
                end
            end
            doNext(amount)
        end
    else
        -- TradeSkill – DoTradeSkill supports a count argument
        local idx = ns.Scanner:FindTradeSkillIndex(recipe.name)
        if not idx then
            ns.TP:Print(L["RECIPE_NOT_FOUND_TRADESKILL"])
            self.remainingAmount = 0
            return false
        end
        if DoTradeSkill then DoTradeSkill(idx, amount) end
    end

    return true
end

--- Called from core.lua on UNIT_SPELLCAST_SUCCEEDED for TradeSkill crafts.
function Crafting:OnCraftCompleted()
    if self.remainingAmount > 0 then
        self.remainingAmount = self.remainingAmount - 1
        self:UpdateAmountBox()
    end
end

--- Push the remaining count into the amount box (minimum display is 1).
--- Also updates button states based on current craftability.
function Crafting:UpdateAmountBox()
    local box = ns.RecipeView and ns.RecipeView.amtBox
    if box then
        box:SetText(tostring(math.max(1, self.remainingAmount)))
    end
    -- Update button states after crafting changes inventory
    if ns.RecipeView and ns.RecipeView.craftBtn then
        local r = ns.RecipeView.recipe
        local canCraft = r and ns.Inventory:CanCraftCount(r) > 0
        if canCraft then
            ns.RecipeView.craftAllBtn:Enable()
            ns.RecipeView.craftBtn:Enable()
            ns.RecipeView.styleEnabled(ns.RecipeView.craftAllBtn)
            ns.RecipeView.styleEnabled(ns.RecipeView.craftBtn)
        else
            ns.RecipeView.craftAllBtn:Disable()
            ns.RecipeView.craftBtn:Disable()
            ns.RecipeView.styleDisabled(ns.RecipeView.craftAllBtn)
            ns.RecipeView.styleDisabled(ns.RecipeView.craftBtn)
        end
    end
end

---------------------------------------------------------------------------
-- Pending-craft resolution  (called from event handlers)
---------------------------------------------------------------------------
function Crafting:TryExecutePending()
    local p = self.pendingCraft
    if not p or not p.recipe then
        self.pendingCraft = nil
        return
    end
    if not isProfOpen(p.recipe) then return end  -- wait for correct window

    local recipe, amount = p.recipe, p.amount
    self.pendingCraft = nil
    self:ExecuteNow(recipe, amount)
end

---------------------------------------------------------------------------
-- Stop  (cancels repeating DoCraft loop and pending craft)
---------------------------------------------------------------------------
function Crafting:Stop()
    self.isActive        = false
    self.pendingCraft    = nil
    self.remainingAmount = 0
    self:UpdateAmountBox()
end
