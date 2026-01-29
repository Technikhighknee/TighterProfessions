---------------------------------------------------------------------------
-- locale/zhTW.lua -- Traditional Chinese
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("zhTW", {
    -- Addon messages
    LOADED_MSG = "已載入 -- /tp 開啟/關閉視窗。",
    MANUAL_SCAN = "手動掃描已觸發。",
    WINDOW_RESET = "視窗位置已重置。",
    CACHE_CLEARED = "配方快取已清除。重新開啟各專業以重新掃描。",
    CRAFTING_STOPPED = "製作已停止。",
    LIBSTUB_MISSING = "缺少LibStub。請將Ace3函式庫複製到Libs資料夾（參見README）。",
    ACEADDON_MISSING = "未找到AceAddon-3.0。",
    RECIPE_NOT_FOUND_CRAFT = "在開啟的製作視窗中未找到配方。",
    RECIPE_NOT_FOUND_TRADESKILL = "在開啟的專業視窗中未找到配方。",
    COULD_NOT_OPEN = "無法開啟%s。該角色是否已學習此專業？",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "搜尋配方/材料...",
    CRAFT = "製作",
    CRAFT_ALL = "全部製作",
    CLOSE = "關閉",
    REAGENTS = "材料：",
    REQUIRES = "需要：%s",
    COST = "成本：%s",
    PROFIT = "利潤：%s",
    NO_RECIPE_SELECTED = "未選擇配方",

    -- Filters
    FILTER_CRAFTABLE = "可製作",
    FILTER_XP_GAIN = "獲得經驗",
    FILTER_PROFIT = "利潤",

    -- Options
    OPT_PROF_PRIORITY = "專業順序",
    OPT_PROF_PRIORITY_DESC = "設置列表中專業的顯示順序。",
    OPT_LANGUAGE = "語言",
    OPT_LANGUAGE_DESC = "選擇插件語言。",
})
