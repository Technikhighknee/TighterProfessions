---------------------------------------------------------------------------
-- util/Locale.lua -- Custom locale system with on-the-fly language switching
---------------------------------------------------------------------------
local _, ns = ...

-- Store all locale tables here
ns.AllLocales = {}

-- Available languages (display names)
ns.LanguageNames = {
    enUS = "English",
    deDE = "Deutsch",
    frFR = "Français",
    esES = "Español (ES)",
    esMX = "Español (MX)",
    ptBR = "Português",
    ruRU = "Русский",
    koKR = "한국어",
    zhCN = "简体中文",
    zhTW = "繁體中文",
    itIT = "Italiano",
}

-- Register a locale's strings
function ns.RegisterLocale(locale, strings)
    ns.AllLocales[locale] = strings
end

-- Get the currently selected language (fallback to system locale, then enUS)
function ns.GetSelectedLanguage()
    if ns.db and ns.db.profile and ns.db.profile.language then
        return ns.db.profile.language
    end
    return GetLocale()
end

-- Create the L proxy table with metatable for dynamic lookup
ns.L = setmetatable({}, {
    __index = function(_, key)
        local lang = ns.GetSelectedLanguage()
        local strings = ns.AllLocales[lang]
        if strings and strings[key] then
            return strings[key]
        end
        -- Fallback to English
        local enStrings = ns.AllLocales["enUS"]
        if enStrings and enStrings[key] then
            return enStrings[key]
        end
        -- Return key if not found
        return key
    end,
    __newindex = function(_, key, value)
        -- Allow setting strings (used by AceLocale compatibility)
        local lang = ns.GetSelectedLanguage()
        local strings = ns.AllLocales[lang]
        if strings then
            strings[lang][key] = value
        end
    end,
})

-- Refresh all UI text elements (called when language changes)
function ns.RefreshLocaleUI()
    local L = ns.L

    -- Update main frame title
    if ns.TP and ns.TP.mainFrame then
        local titleText = _G["TighterProfessionsFrameTitleText"]
        if titleText then
            titleText:SetText(L["TITLE"])
        end
    end

    -- Update filter checkbox labels
    local cbCraftableText = _G["TPFilterCraftableText"]
    if cbCraftableText then cbCraftableText:SetText(L["FILTER_CRAFTABLE"]) end

    local cbExperienceText = _G["TPFilterExperienceText"]
    if cbExperienceText then cbExperienceText:SetText(L["FILTER_XP_GAIN"]) end

    local cbProfitText = _G["TPFilterProfitText"]
    if cbProfitText then cbProfitText:SetText(L["FILTER_PROFIT"]) end

    -- Refresh the recipe list
    if ns.RecipesList then
        ns.RecipesList:Refresh()
    end

    -- Refresh the recipe view (buttons, labels)
    if ns.RecipeView then
        ns.RecipeView:RefreshLocale()
    end
end
