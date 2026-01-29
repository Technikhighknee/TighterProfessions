---------------------------------------------------------------------------
-- logic/Filters.lua -- Recipe filtering and profit calculation
---------------------------------------------------------------------------
local _, ns = ...
ns.Filters = {}
local Filters = ns.Filters

local strlower = string.lower

---------------------------------------------------------------------------
-- Profit calculation  (requires Auctionator)
---------------------------------------------------------------------------
local AH_CUT = 0.95

--- Returns profit, craftCost, resultRevenue  (copper) or nil.
function ns.GetRecipeProfit(recipe)
    if not (Auctionator and Auctionator.API and Auctionator.API.v1) then
        return nil
    end

    local ok, profit, cost, revenue = pcall(function()
        local api       = Auctionator.API.v1
        local getAH     = api.GetAuctionPriceByItemID
        local getVendor = api.GetVendorPriceByItemID
        local getAHLink = api.GetAuctionPriceByItemLink

        -- Reagent cost (vendor preferred, then AH)
        local craftCost = 0
        for _, ing in ipairs(recipe.ingredients or {}) do
            if not ing.itemID then return nil end
            local vp = getVendor and getVendor("TighterProfessions", ing.itemID)
            local ap = getAH("TighterProfessions", ing.itemID)
            local unitPrice = (vp and vp > 0 and vp) or (ap and ap > 0 and ap)
            if not unitPrice then return nil end
            craftCost = craftCost + unitPrice * (ing.count or 1)
        end

        -- Result revenue (AH price after 5% cut, x numMade)
        local resultAH
        if recipe.resultItemLink and getAHLink then
            resultAH = getAHLink("TighterProfessions", recipe.resultItemLink)
        end
        if (not resultAH or resultAH <= 0) and recipe.resultItemID then
            resultAH = getAH("TighterProfessions", recipe.resultItemID)
        end
        if not resultAH or resultAH <= 0 then return nil end

        local numMade       = recipe.numMade or 1
        local resultRevenue = math.floor(resultAH * numMade * AH_CUT)
        return resultRevenue - craftCost, craftCost, resultRevenue
    end)

    if not ok then return nil end
    return profit, cost, revenue
end

---------------------------------------------------------------------------
-- Text search
---------------------------------------------------------------------------
local function ciContains(haystack, needle)
    if not haystack or not needle or needle == "" then return true end
    return strlower(haystack):find(strlower(needle), 1, true) ~= nil
end

local function matchesText(recipe, text)
    if not text or text == "" then return true end
    if ciContains(recipe.name, text)       then return true end
    if ciContains(recipe.profession, text) then return true end
    if ciContains(recipe.resultName, text) then return true end
    for _, ing in ipairs(recipe.ingredients or {}) do
        if ciContains(ing.name, text) then return true end
    end
    return false
end

---------------------------------------------------------------------------
-- Apply all active filters
---------------------------------------------------------------------------
function Filters:Apply(recipes, text, onlyCraftable, onlyExperience, onlyProfit)
    local out = {}
    for _, r in ipairs(recipes) do
        local dominated = false

        if not matchesText(r, text) then dominated = true end

        if not dominated and onlyCraftable then
            local cc = r.canCraftCount or ns.Inventory:CanCraftCount(r)
            if cc <= 0 then dominated = true end
        end

        if not dominated and onlyExperience then
            if r.skillType == "trivial" then dominated = true end
        end

        if not dominated and onlyProfit then
            local profit = ns.GetRecipeProfit(r)
            if not profit or profit <= 0 then dominated = true end
        end

        if not dominated then
            out[#out + 1] = r
        end
    end
    return out
end
