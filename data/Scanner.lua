---------------------------------------------------------------------------
-- data/Scanner.lua -- Scans open profession windows, caches recipes
--
-- TradeSkill and Craft APIs are nearly identical but use different
-- function names.  An adapter table normalises each into a common
-- interface so a single scanProfession() handles both.
---------------------------------------------------------------------------
local _, ns = ...
ns.Scanner = {}
local Scanner = ns.Scanner

Scanner.isTradeSkillOpen  = false
Scanner.isCraftOpen       = false
Scanner.currentProfession = nil
Scanner.knownProfessions  = {}  -- { [profName] = true }

---------------------------------------------------------------------------
-- API adapters
---------------------------------------------------------------------------
local tradeSkillAPI = {
    getProfName = function()
        return GetTradeSkillLine()
    end,
    expandHeaders = function()
        -- Expand bottom-up so that newly-revealed indices appear below
        -- the current position and don't shift headers we haven't visited.
        for i = (GetNumTradeSkills() or 0), 1, -1 do
            local _, stype, _, isExp = GetTradeSkillInfo(i)
            if stype == "header" and not isExp and ExpandTradeSkillSubClass then
                ExpandTradeSkillSubClass(i)
            end
        end
    end,
    getNumEntries  = function()    return GetNumTradeSkills() or 0 end,
    getInfo        = function(i)
        local name, stype, numAvail = GetTradeSkillInfo(i)
        return name, stype, numAvail
    end,
    getIcon        = function(i) return GetTradeSkillIcon(i) end,
    getItemLink    = function(i) return GetTradeSkillItemLink(i) end,
    getNumReagents = function(i) return GetTradeSkillNumReagents(i) or 0 end,
    getReagentInfo = function(i, j) return GetTradeSkillReagentInfo(i, j) end,
    getReagentLink = function(i, j)
        return GetTradeSkillReagentItemLink
           and GetTradeSkillReagentItemLink(i, j)
    end,
    getNumMade = function(i)
        if not GetTradeSkillNumMade then return 1 end
        return GetTradeSkillNumMade(i) or 1
    end,
    getTool = function(i)
        return GetTradeSkillTools and GetTradeSkillTools(i)
    end,
}

local craftAPI = {
    getProfName = function()
        local name
        if GetCraftDisplaySkillLine then name = GetCraftDisplaySkillLine() end
        if (not name or name == "") and CraftFrameTitleText then
            name = CraftFrameTitleText:GetText()
        end
        return name or "Enchanting"
    end,
    expandHeaders = function()
        for i = (GetNumCrafts() or 0), 1, -1 do
            local _, _, ctype, _, isExp = GetCraftInfo(i)
            if ctype == "header" and not isExp and ExpandCraftSkillLine then
                ExpandCraftSkillLine(i)
            end
        end
    end,
    getNumEntries  = function()    return GetNumCrafts() or 0 end,
    getInfo        = function(i)
        local name, _, ctype, numAvail = GetCraftInfo(i)
        return name, ctype, numAvail
    end,
    getIcon        = function(i) return GetCraftIcon(i) end,
    getItemLink    = function(i) return GetCraftItemLink and GetCraftItemLink(i) end,
    getNumReagents = function(i) return GetCraftNumReagents(i) or 0 end,
    getReagentInfo = function(i, j)
        return GetCraftReagentInfo and GetCraftReagentInfo(i, j)
    end,
    getReagentLink = function(i, j)
        return GetCraftReagentItemLink and GetCraftReagentItemLink(i, j)
    end,
    getNumMade = nil,   -- Craft API has no numMade
    getTool = function(i)
        return GetCraftSpellFocus and GetCraftSpellFocus(i)
    end,
}

---------------------------------------------------------------------------
-- Generic scan (shared by TradeSkill and Craft)
---------------------------------------------------------------------------
local function scanProfession(api, isCraft)
    local profName = api.getProfName()
    if not profName or profName == "" or profName == "UNKNOWN" then return end

    if isCraft then
        Scanner.isCraftOpen = true
    else
        Scanner.isTradeSkillOpen = true
    end
    Scanner.currentProfession = profName

    -- Track this as a known profession
    Scanner.knownProfessions[profName] = true

    api.expandHeaders()

    local numEntries = api.getNumEntries()
    local recipes    = {}
    local category   = ""
    local recipeIdx  = 0

    for i = 1, numEntries do
        local name, entryType, numAvail = api.getInfo(i)

        if entryType == "header" then
            category = name or ""
        elseif name then
            recipeIdx = recipeIdx + 1
            local icon     = api.getIcon(i)
            local itemLink = api.getItemLink(i)
            local resName, resID = ns.Links:ParseItemLink(itemLink)

            local numReag     = api.getNumReagents(i)
            local ingredients = {}
            for j = 1, numReag do
                local rName, rTex, rCount, rHave = api.getReagentInfo(i, j)
                local rLink  = api.getReagentLink(i, j)
                local _, rID = ns.Links:ParseItemLink(rLink)
                if rName then
                    ingredients[#ingredients + 1] = {
                        name   = rName,
                        icon   = rTex,
                        count  = rCount or 1,
                        have   = rHave or 0,
                        itemID = rID,
                    }
                end
            end

            local numMade      = api.getNumMade and api.getNumMade(i) or 1
            local toolName     = api.getTool and api.getTool(i)

            local key = profName .. ":" .. name
            recipes[key] = {
                key            = key,
                profession     = profName,
                name           = name,
                category       = category,
                icon           = icon,
                skillType      = entryType or "unknown",
                numAvailable   = numAvail or 0,
                numMade        = numMade,
                resultItemLink = itemLink,
                resultItemID   = resID,
                resultName     = resName or name,
                ingredients    = ingredients,
                isCraft        = isCraft,
                toolName       = toolName,
                scanIndex      = recipeIdx,
            }
        end
    end

    if ns.db and ns.db.char then
        ns.db.char.recipes[profName] = recipes
    end

    -- Update profession priority list (adds new profs, removes unlearned ones)
    Scanner:UpdateProfessionPriority()

    -- Refresh UI after scan completes
    C_Timer.After(0, function()
        if ns.Inventory then ns.Inventory:RefreshCounts() end
        if ns.RecipesList then ns.RecipesList:Refresh() end
        if ns.RecipeView  then ns.RecipeView:Refresh()  end
    end)
end

---------------------------------------------------------------------------
-- Public scan entry points
---------------------------------------------------------------------------
function Scanner:ScanTradeSkill()
    if not GetTradeSkillLine then return end
    scanProfession(tradeSkillAPI, false)
end

function Scanner:ScanCraft()
    if not GetNumCrafts then return end
    scanProfession(craftAPI, true)
end

---------------------------------------------------------------------------
-- Close handlers
---------------------------------------------------------------------------
function Scanner:OnTradeSkillClose()
    self.isTradeSkillOpen = false
end

function Scanner:OnCraftClose()
    self.isCraftOpen = false
end

---------------------------------------------------------------------------
-- Accessors
---------------------------------------------------------------------------

--- Merge all cached professions into one flat table keyed by recipe key.
function Scanner:GetAllRecipes()
    local all = {}
    if not ns.db or not ns.db.char then return all end
    for _, profRecipes in pairs(ns.db.char.recipes or {}) do
        for k, v in pairs(profRecipes) do
            all[k] = v
        end
    end
    return all
end

--- Return a sorted array of all cached recipes.
--- Follows vanilla profession window order: grouped by profession (user-defined priority),
--- then by scanIndex within each profession (which preserves Blizzard's category/level order).
--- Favorites float to the top within each profession.
function Scanner:GetSortedRecipes()
    local all    = self:GetAllRecipes()
    local sorted = {}
    for _, r in pairs(all) do sorted[#sorted + 1] = r end

    local favs     = (ns.db and ns.db.char and ns.db.char.favorites) or {}
    local profile  = ns.db and ns.db.profile or {}
    local profPrio = profile.professionPriority or {}

    -- Build priority lookup: profName -> priority number (lower = higher priority)
    local prioLookup = {}
    for i, profName in ipairs(profPrio) do
        prioLookup[profName] = i
    end
    local maxPrio = #profPrio + 1

    table.sort(sorted, function(a, b)
        -- 1. Group by profession (using user-defined priority order)
        if a.profession ~= b.profession then
            local pa = prioLookup[a.profession] or maxPrio
            local pb = prioLookup[b.profession] or maxPrio
            if pa ~= pb then return pa < pb end
            return a.profession < b.profession
        end

        -- 2. Within same profession: favorites float to top
        local fa = favs[a.key] and 1 or 0
        local fb = favs[b.key] and 1 or 0
        if fa ~= fb then return fa > fb end

        -- 3. Preserve vanilla order (scanIndex = Blizzard's category/level order)
        local sa = a.scanIndex or 0
        local sb = b.scanIndex or 0
        return sa < sb
    end)
    return sorted
end

--- Get list of known professions (from scanned recipes)
function Scanner:GetKnownProfessions()
    local profs = {}
    if ns.db and ns.db.char and ns.db.char.recipes then
        for profName, _ in pairs(ns.db.char.recipes) do
            profs[#profs + 1] = profName
        end
    end
    table.sort(profs)
    return profs
end

--- Update the profession priority list: remove unlearned, keep order of existing
function Scanner:UpdateProfessionPriority()
    if not ns.db or not ns.db.profile then return end

    local knownSet = {}
    for _, prof in ipairs(self:GetKnownProfessions()) do
        knownSet[prof] = true
    end

    local oldPrio = ns.db.profile.professionPriority or {}
    local newPrio = {}
    local seen = {}

    -- Keep existing professions that are still known, in their current order
    for _, prof in ipairs(oldPrio) do
        if knownSet[prof] and not seen[prof] then
            newPrio[#newPrio + 1] = prof
            seen[prof] = true
        end
    end

    -- Add any new professions at the end
    for prof in pairs(knownSet) do
        if not seen[prof] then
            newPrio[#newPrio + 1] = prof
        end
    end

    ns.db.profile.professionPriority = newPrio
end

--- Find a recipe index by name in the currently open TradeSkill window.
function Scanner:FindTradeSkillIndex(recipeName)
    if not self.isTradeSkillOpen or not GetNumTradeSkills then return nil end
    for i = 1, GetNumTradeSkills() do
        local n, t = GetTradeSkillInfo(i)
        if n == recipeName and t ~= "header" then return i end
    end
    return nil
end

--- Find a recipe index by name in the currently open Craft window.
function Scanner:FindCraftIndex(recipeName)
    if not self.isCraftOpen or not GetNumCrafts then return nil end
    for i = 1, GetNumCrafts() do
        local n, _, t = GetCraftInfo(i)
        if n == recipeName and t ~= "header" then return i end
    end
    return nil
end
