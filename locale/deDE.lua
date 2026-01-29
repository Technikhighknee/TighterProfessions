---------------------------------------------------------------------------
-- locale/deDE.lua -- German
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("deDE", {
    -- Addon messages
    LOADED_MSG = "geladen -- /tp um das Fenster umzuschalten.",
    MANUAL_SCAN = "Manueller Scan ausgelöst.",
    WINDOW_RESET = "Fensterposition zurückgesetzt.",
    CACHE_CLEARED = "Rezept-Cache geleert. Öffne jeden Beruf erneut zum Scannen.",
    CRAFTING_STOPPED = "Herstellung gestoppt.",
    LIBSTUB_MISSING = "LibStub fehlt. Kopiere Ace3-Bibliotheken in den Libs-Ordner (siehe README).",
    ACEADDON_MISSING = "AceAddon-3.0 nicht gefunden.",
    RECIPE_NOT_FOUND_CRAFT = "Rezept nicht im offenen Handwerksfenster gefunden.",
    RECIPE_NOT_FOUND_TRADESKILL = "Rezept nicht im offenen Berufsfenster gefunden.",
    COULD_NOT_OPEN = "Konnte %s nicht öffnen. Ist der Beruf diesem Charakter bekannt?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Rezepte / Zutaten suchen...",
    CRAFT = "Erstellen",
    CRAFT_ALL = "Alle erst.",
    CLOSE = "Schließen",
    REAGENTS = "Reagenzien:",
    REQUIRES = "Benötigt: %s",
    COST = "Kosten: %s",
    PROFIT = "Gewinn: %s",
    NO_RECIPE_SELECTED = "Kein Rezept ausgewählt",

    -- Filters
    FILTER_CRAFTABLE = "Herstellbar",
    FILTER_XP_GAIN = "EP-Gewinn",
    FILTER_PROFIT = "Gewinn",

    -- Options
    OPT_PROF_PRIORITY = "Berufsreihenfolge",
    OPT_PROF_PRIORITY_DESC = "Anzeigereihenfolge der Berufe in der Rezeptliste.",
    OPT_LANGUAGE = "Sprache",
    OPT_LANGUAGE_DESC = "Wähle die Addon-Sprache.",
})
