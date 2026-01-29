---------------------------------------------------------------------------
-- locale/zhCN.lua -- Simplified Chinese
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("zhCN", {
    -- Addon messages
    LOADED_MSG = "已加载 -- /tp 打开/关闭窗口。",
    MANUAL_SCAN = "手动扫描已触发。",
    WINDOW_RESET = "窗口位置已重置。",
    CACHE_CLEARED = "配方缓存已清除。重新打开各专业以重新扫描。",
    CRAFTING_STOPPED = "制作已停止。",
    LIBSTUB_MISSING = "缺少LibStub。请将Ace3库复制到Libs文件夹（参见README）。",
    ACEADDON_MISSING = "未找到AceAddon-3.0。",
    RECIPE_NOT_FOUND_CRAFT = "在打开的制作窗口中未找到配方。",
    RECIPE_NOT_FOUND_TRADESKILL = "在打开的专业窗口中未找到配方。",
    COULD_NOT_OPEN = "无法打开%s。该角色是否已学习此专业？",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "搜索配方/材料...",
    CRAFT = "制作",
    CRAFT_ALL = "全部制作",
    CLOSE = "关闭",
    REAGENTS = "材料：",
    REQUIRES = "需要：%s",
    COST = "成本：%s",
    PROFIT = "利润：%s",
    NO_RECIPE_SELECTED = "未选择配方",

    -- Filters
    FILTER_CRAFTABLE = "可制作",
    FILTER_XP_GAIN = "获得经验",
    FILTER_PROFIT = "利润",

    -- Options
    OPT_PROF_PRIORITY = "专业顺序",
    OPT_PROF_PRIORITY_DESC = "设置列表中专业的显示顺序。",
    OPT_LANGUAGE = "语言",
    OPT_LANGUAGE_DESC = "选择插件语言。",
})
