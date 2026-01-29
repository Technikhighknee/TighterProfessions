---------------------------------------------------------------------------
-- logic/Inventory.lua -- Bag counting and craftable-count calculation
---------------------------------------------------------------------------
local _, ns = ...
ns.Inventory = {}
local Inventory = ns.Inventory

--- Return how many of a given item the player has in bags.
function Inventory:GetCount(itemID, itemName)
    if itemID and itemID > 0 then
        local n = GetItemCount(itemID, false)
        if n then return n end
    end
    if itemName and itemName ~= "" then
        local ok, n = pcall(GetItemCount, itemName, false)
        if ok and n then return n end
    end
    return 0
end

--- Maximum number of times a recipe can be crafted from bag contents.
function Inventory:CanCraftCount(recipe)
    if not recipe or not recipe.ingredients then return 0 end
    local minCrafts = math.huge
    for _, ing in ipairs(recipe.ingredients) do
        local have = self:GetCount(ing.itemID, ing.name)
        local need = math.max(1, ing.count or 1)
        local crafts = math.floor(have / need)
        if crafts < minCrafts then minCrafts = crafts end
    end
    if minCrafts == math.huge then return 1 end
    return minCrafts
end

--- Update canCraftCount and ingredient have-counts on every cached recipe.
function Inventory:RefreshCounts()
    if not ns.db or not ns.db.char then return end
    for _, profRecipes in pairs(ns.db.char.recipes or {}) do
        for _, recipe in pairs(profRecipes) do
            for _, ing in ipairs(recipe.ingredients) do
                ing.have = self:GetCount(ing.itemID, ing.name)
            end
            recipe.canCraftCount = self:CanCraftCount(recipe)
        end
    end
end
