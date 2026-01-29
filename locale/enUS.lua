---------------------------------------------------------------------------
-- locale/enUS.lua -- English (base locale)
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("enUS", {
    -- Addon messages
    LOADED_MSG = "loaded -- /tp to toggle window.",
    MANUAL_SCAN = "Manual scan triggered.",
    WINDOW_RESET = "Window position reset.",
    CACHE_CLEARED = "Recipe cache cleared. Re-open each profession to rescan.",
    CRAFTING_STOPPED = "Crafting stopped.",
    LIBSTUB_MISSING = "LibStub is missing. Copy Ace3 libraries into the Libs folder (see README).",
    ACEADDON_MISSING = "AceAddon-3.0 not found.",
    RECIPE_NOT_FOUND_CRAFT = "Recipe not found in the open Craft window.",
    RECIPE_NOT_FOUND_TRADESKILL = "Recipe not found in the open Trade Skill window.",
    COULD_NOT_OPEN = "Could not open %s. Is the profession known on this character?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Search recipes / ingredients...",
    CRAFT = "Craft",
    CRAFT_ALL = "Craft All",
    CLOSE = "Close",
    REAGENTS = "Reagents:",
    REQUIRES = "Requires: %s",
    COST = "Cost: %s",
    PROFIT = "Profit: %s",
    NO_RECIPE_SELECTED = "No recipe selected",

    -- Filters
    FILTER_CRAFTABLE = "Craftable",
    FILTER_XP_GAIN = "XP Gain",
    FILTER_PROFIT = "Profit",

    -- Options
    OPT_PROF_PRIORITY = "Profession Order",
    OPT_PROF_PRIORITY_DESC = "Set the display order of professions in the recipe list.",
    OPT_LANGUAGE = "Language",
    OPT_LANGUAGE_DESC = "Select the addon language.",
})
