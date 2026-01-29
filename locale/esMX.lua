---------------------------------------------------------------------------
-- locale/esMX.lua -- Spanish (Latin America)
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("esMX", {
    -- Addon messages
    LOADED_MSG = "cargado -- /tp para mostrar/ocultar ventana.",
    MANUAL_SCAN = "Escaneo manual iniciado.",
    WINDOW_RESET = "Posición de ventana restablecida.",
    CACHE_CLEARED = "Caché de recetas borrada. Vuelve a abrir cada profesión para escanear.",
    CRAFTING_STOPPED = "Fabricación detenida.",
    LIBSTUB_MISSING = "Falta LibStub. Copia las bibliotecas Ace3 en la carpeta Libs (ver README).",
    ACEADDON_MISSING = "AceAddon-3.0 no encontrado.",
    RECIPE_NOT_FOUND_CRAFT = "Receta no encontrada en la ventana de artesanía abierta.",
    RECIPE_NOT_FOUND_TRADESKILL = "Receta no encontrada en la ventana de profesión abierta.",
    COULD_NOT_OPEN = "No se pudo abrir %s. ¿Este personaje conoce la profesión?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Buscar recetas / componentes...",
    CRAFT = "Crear",
    CRAFT_ALL = "Crear todo",
    CLOSE = "Cerrar",
    REAGENTS = "Componentes:",
    REQUIRES = "Requiere: %s",
    COST = "Costo: %s",
    PROFIT = "Ganancia: %s",
    NO_RECIPE_SELECTED = "Ninguna receta seleccionada",

    -- Filters
    FILTER_CRAFTABLE = "Fabricable",
    FILTER_XP_GAIN = "Gana XP",
    FILTER_PROFIT = "Ganancia",

    -- Options
    OPT_PROF_PRIORITY = "Orden de profesiones",
    OPT_PROF_PRIORITY_DESC = "Establecer el orden de las profesiones en la lista.",
    OPT_LANGUAGE = "Idioma",
    OPT_LANGUAGE_DESC = "Seleccionar el idioma del addon.",
})
