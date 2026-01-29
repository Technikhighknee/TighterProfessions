---------------------------------------------------------------------------
-- locale/koKR.lua -- Korean
---------------------------------------------------------------------------
local _, ns = ...

ns.RegisterLocale("koKR", {
    -- Addon messages
    LOADED_MSG = "로드됨 -- /tp 로 창 열기/닫기.",
    MANUAL_SCAN = "수동 스캔 시작됨.",
    WINDOW_RESET = "창 위치 초기화됨.",
    CACHE_CLEARED = "제조법 캐시 삭제됨. 각 전문기술을 다시 열어 스캔하세요.",
    CRAFTING_STOPPED = "제작 중지됨.",
    LIBSTUB_MISSING = "LibStub이 없습니다. Ace3 라이브러리를 Libs 폴더에 복사하세요 (README 참조).",
    ACEADDON_MISSING = "AceAddon-3.0을 찾을 수 없습니다.",
    RECIPE_NOT_FOUND_CRAFT = "열린 제작 창에서 제조법을 찾을 수 없습니다.",
    RECIPE_NOT_FOUND_TRADESKILL = "열린 전문기술 창에서 제조법을 찾을 수 없습니다.",
    COULD_NOT_OPEN = "%s을(를) 열 수 없습니다. 이 캐릭터가 해당 전문기술을 알고 있나요?",

    -- UI elements
    TITLE = "TighterProfessions",
    SEARCH_PLACEHOLDER = "제조법 / 재료 검색...",
    CRAFT = "제작",
    CRAFT_ALL = "모두 제작",
    CLOSE = "닫기",
    REAGENTS = "재료:",
    REQUIRES = "필요: %s",
    COST = "비용: %s",
    PROFIT = "이익: %s",
    NO_RECIPE_SELECTED = "선택된 제조법 없음",

    -- Filters
    FILTER_CRAFTABLE = "제작 가능",
    FILTER_XP_GAIN = "경험치 획득",
    FILTER_PROFIT = "이익",

    -- Options
    OPT_PROF_PRIORITY = "전문기술 순서",
    OPT_PROF_PRIORITY_DESC = "목록에서 전문기술의 표시 순서를 설정합니다.",
    OPT_LANGUAGE = "언어",
    OPT_LANGUAGE_DESC = "애드온 언어를 선택합니다.",
})
