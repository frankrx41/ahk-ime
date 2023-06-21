;*******************************************************************************
; This file ONLY used for debug
;
; Please stop track this file
; You can use the following command:
;   - To track: `git update-index --no-skip-worktree src\utils\ime_debug.ahk`
;   - To skip:  `git update-index --skip-worktree src\utils\ime_debug.ahk`
;*******************************************************************************
; Static
; debug_level
;   - 0: hide
;   - 1: display only hit count and time
;   - 2: show full
ImeDebugGetProfilerText(name, debug_level)
{
    local
    debug_text := ""

    if( debug_level >= 1 )
    {
        debug_text .= "`n" . name . "*" ImeProfilerGeneralGetTraceCount(name) ":"
        debug_text .= "(" ImeProfilerGeneralGetTotalCallTime(name) ") "
    }
    if( debug_level >= 2 ) {
        debug_text .= ImeProfilerGeneralGetProfileText(name)
    }

    return debug_text
}

ImeDebugGetDisplayText()
{
    local
    debug_text := ""
    debug_level := ImeDebugLevelGet()
    if( debug_level > 0 )
    {
        ; Comment out the debug info you don't want
        ; If you want add new debug info, do follow:
        ; ```
        ;   ImeProfilerBegin()
        ;   ImeProfilerEnd(profile_text)
        ; ```
        ; See ime_profiler.ahk for detail.

        name_list := ImeProfilerGeneralGetAllNameList()
        name_list := ["PinyinSqlExecuteGetTable", "PinyinSqlGetResult"]
        name_list := ["PinyinSqlExecuteGetTable"]
        name_list := ["PinyinSplitterInputStringNormal", "PinyinSplitterCheckDBWeight", "PinyinSqlGetWeight", "ImeCandidateUpdateResult", "SelectorFixupSelectIndex", "PinyinSqlExecuteGetTable"]
        name_list := ["PinyinSqlGetWeight"]
        name_list := ["TranslatorResultListFilterByRadical"]
        name_list := ["ImeTranslateFilterResult", "SelectorFindGraceResultIndex", "SelectorCheckTotalWeight"]
        name_list := ["SelectorCheckTotalWeight", "SelectorFindGraceResultIndex"]
        name_list := ["PinyinSplitterCheckDBWeight"]
        name_list := ["PinyinSplitterInputStringNormal","PinyinSplitterInputStringSimple"]
        name_list := ["PinyinSplitterCheckIsMaxWeightWord"]

        for index, element in name_list
        {
            if( ImeProfilerGeneralHasKey(element) )
            {
                debug_text .= ImeDebugGetProfilerText(element, debug_level)
            }
        }

        if( ImeProfilerGeneralHasKey("Temporary") )
        {
            debug_text .= ImeDebugGetProfilerText("Temporary", 2)
        }
        debug_text .= "`n----------------" debug_level "-"
        if( ImeProfilerGeneralHasKey("Assert") )
        {
            debug_text .= ImeDebugGetProfilerText("Assert", 2)
        }
    }
    else
    {
        if( ImeProfilerGeneralHasKey("Assert") )
        {
            debug_text .= "`n----------------" debug_level "-"
            debug_text .= ImeDebugGetProfilerText("Assert", 2)
        }
    }

    return debug_text
}
