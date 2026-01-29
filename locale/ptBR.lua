---------------------------------------------------------------------------
-- locale/ptBR.lua -- Portuguese (Brazil)
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("ptBR", {
    -- Addon messages
    LOADED_MSG = "carregado -- /tp para mostrar/ocultar janela.",
    MANUAL_SCAN = "Escaneamento manual iniciado.",
    WINDOW_RESET = "Posição da janela redefinida.",
    CACHE_CLEARED = "Cache de receitas limpo. Reabra cada profissão para escanear.",
    CRAFTING_STOPPED = "Fabricação interrompida.",
    LIBSTUB_MISSING = "LibStub ausente. Copie as bibliotecas Ace3 para a pasta Libs (veja README).",
    ACEADDON_MISSING = "AceAddon-3.0 não encontrado.",
    RECIPE_NOT_FOUND_CRAFT = "Receita não encontrada na janela de criação aberta.",
    RECIPE_NOT_FOUND_TRADESKILL = "Receita não encontrada na janela de profissão aberta.",
    COULD_NOT_OPEN = "Não foi possível abrir %s. Este personagem conhece a profissão?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Buscar receitas / reagentes...",
    CRAFT = "Criar",
    CRAFT_ALL = "Tudo",
    CLOSE = "Fechar",
    REAGENTS = "Reagentes:",
    REQUIRES = "Requer: %s",
    COST = "Custo: %s",
    PROFIT = "Lucro: %s",
    NO_RECIPE_SELECTED = "Nenhuma receita selecionada",

    -- Filters
    FILTER_CRAFTABLE = "Criável",
    FILTER_XP_GAIN = "Ganha XP",
    FILTER_PROFIT = "Lucro",

    -- Options
    OPT_PROF_PRIORITY = "Ordem das profissões",
    OPT_PROF_PRIORITY_DESC = "Definir a ordem de exibição das profissões na lista.",
    OPT_LANGUAGE = "Idioma",
    OPT_LANGUAGE_DESC = "Selecionar o idioma do addon.",
})
