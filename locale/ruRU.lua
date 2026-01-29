---------------------------------------------------------------------------
-- locale/ruRU.lua -- Russian
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("ruRU", {
    -- Addon messages
    LOADED_MSG = "загружен -- /tp для открытия/закрытия окна.",
    MANUAL_SCAN = "Ручное сканирование запущено.",
    WINDOW_RESET = "Позиция окна сброшена.",
    CACHE_CLEARED = "Кэш рецептов очищен. Откройте каждую профессию для повторного сканирования.",
    CRAFTING_STOPPED = "Создание остановлено.",
    LIBSTUB_MISSING = "LibStub отсутствует. Скопируйте библиотеки Ace3 в папку Libs (см. README).",
    ACEADDON_MISSING = "AceAddon-3.0 не найден.",
    RECIPE_NOT_FOUND_CRAFT = "Рецепт не найден в открытом окне ремесла.",
    RECIPE_NOT_FOUND_TRADESKILL = "Рецепт не найден в открытом окне профессии.",
    COULD_NOT_OPEN = "Не удалось открыть %s. Эта профессия известна персонажу?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "Поиск рецептов / реагентов...",
    CRAFT = "Создать",
    CRAFT_ALL = "Всё",
    CLOSE = "Закрыть",
    REAGENTS = "Реагенты:",
    REQUIRES = "Требуется: %s",
    COST = "Стоимость: %s",
    PROFIT = "Прибыль: %s",
    NO_RECIPE_SELECTED = "Рецепт не выбран",

    -- Filters
    FILTER_CRAFTABLE = "Доступно",
    FILTER_XP_GAIN = "Даёт опыт",
    FILTER_PROFIT = "Прибыль",

    -- Options
    OPT_PROF_PRIORITY = "Порядок профессий",
    OPT_PROF_PRIORITY_DESC = "Установите порядок отображения профессий в списке.",
    OPT_LANGUAGE = "Язык",
    OPT_LANGUAGE_DESC = "Выберите язык аддона.",
})
