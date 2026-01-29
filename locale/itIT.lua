---------------------------------------------------------------------------
-- locale/itIT.lua -- Italian
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("itIT", {
    -- Addon messages
    LOADED_MSG = "caricato -- /tp per mostrare/nascondere la finestra.",
    MANUAL_SCAN = "Scansione manuale avviata.",
    WINDOW_RESET = "Posizione finestra reimpostata.",
    CACHE_CLEARED = "Cache ricette cancellata. Riapri ogni professione per riscansionare.",
    CRAFTING_STOPPED = "Creazione fermata.",
    LIBSTUB_MISSING = "LibStub mancante. Copia le librerie Ace3 nella cartella Libs (vedi README).",
    ACEADDON_MISSING = "AceAddon-3.0 non trovato.",
    RECIPE_NOT_FOUND_CRAFT = "Ricetta non trovata nella finestra artigianato aperta.",
    RECIPE_NOT_FOUND_TRADESKILL = "Ricetta non trovata nella finestra professione aperta.",
    COULD_NOT_OPEN = "Impossibile aprire %s. Questo personaggio conosce la professione?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Cerca ricette / reagenti...",
    CRAFT = "Crea",
    CRAFT_ALL = "Tutto",
    CLOSE = "Chiudi",
    REAGENTS = "Reagenti:",
    REQUIRES = "Richiede: %s",
    COST = "Costo: %s",
    PROFIT = "Profitto: %s",
    NO_RECIPE_SELECTED = "Nessuna ricetta selezionata",

    -- Filters
    FILTER_CRAFTABLE = "Creabile",
    FILTER_XP_GAIN = "Guadagna XP",
    FILTER_PROFIT = "Profitto",

    -- Options
    OPT_PROF_PRIORITY = "Ordine professioni",
    OPT_PROF_PRIORITY_DESC = "Imposta l'ordine di visualizzazione delle professioni.",
    OPT_LANGUAGE = "Lingua",
    OPT_LANGUAGE_DESC = "Seleziona la lingua dell'addon.",
})
