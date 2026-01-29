---------------------------------------------------------------------------
-- locale/frFR.lua -- French
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("frFR", {
    -- Addon messages
    LOADED_MSG = "chargé -- /tp pour afficher/masquer la fenêtre.",
    MANUAL_SCAN = "Analyse manuelle déclenchée.",
    WINDOW_RESET = "Position de la fenêtre réinitialisée.",
    CACHE_CLEARED = "Cache des recettes vidé. Rouvrez chaque métier pour rescanner.",
    CRAFTING_STOPPED = "Fabrication arrêtée.",
    LIBSTUB_MISSING = "LibStub est manquant. Copiez les bibliothèques Ace3 dans le dossier Libs (voir README).",
    ACEADDON_MISSING = "AceAddon-3.0 non trouvé.",
    RECIPE_NOT_FOUND_CRAFT = "Recette non trouvée dans la fenêtre d'artisanat ouverte.",
    RECIPE_NOT_FOUND_TRADESKILL = "Recette non trouvée dans la fenêtre de métier ouverte.",
    COULD_NOT_OPEN = "Impossible d'ouvrir %s. Ce métier est-il connu de ce personnage?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Rechercher recettes / composants...",
    CRAFT = "Créer",
    CRAFT_ALL = "Tout créer",
    CLOSE = "Fermer",
    REAGENTS = "Composants:",
    REQUIRES = "Requiert: %s",
    COST = "Coût: %s",
    PROFIT = "Profit: %s",
    NO_RECIPE_SELECTED = "Aucune recette sélectionnée",

    -- Filters
    FILTER_CRAFTABLE = "Fabricable",
    FILTER_XP_GAIN = "Gain XP",
    FILTER_PROFIT = "Profit",

    -- Options
    OPT_PROF_PRIORITY = "Ordre des métiers",
    OPT_PROF_PRIORITY_DESC = "Définir l'ordre d'affichage des métiers dans la liste.",
    OPT_LANGUAGE = "Langue",
    OPT_LANGUAGE_DESC = "Sélectionner la langue de l'addon.",
})
