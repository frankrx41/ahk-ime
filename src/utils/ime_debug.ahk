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
        debug_text .= "`n" . name . "*" ImeProfilerGetCount(name) ":"
        debug_text .= "(" ImeProfilerGetTotalTick(name) ") "
    }
    if( debug_level >= 2 ) {
        debug_text .= ImeProfilerGetProfileText(name)
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

        name_list := ["ImeTranslateFilterResult_", "SelectorFindGraceResultIndex_", "SelectorCheckTotalWeight_"]
        name_list := ["PinyinSqlExecuteGetTable_", "PinyinSqlGetResult_"]
        name_list := ["PinyinSqlExecuteGetTable_"]
        name_list := ImeProfilerGetAllNameList()

        name_list := ["ImeInputterUpdateString_", "ImeInputterCallTranslator_", "ImeCandidateUpdateResult_", "SelectorFixupSelectIndex_", "PinyinSplitterInputStringNormal_", "PinyinSqlExecuteGetTable_", "PinyinSplitterCheckDBWeight_", "PinyinSqlGetWeight_"]

        for index, element in name_list
        {
            if( ImeProfilerHasKey(element) )
            {
                debug_text .= ImeDebugGetProfilerText(element, debug_level)
            }
        }

        if( ImeProfilerHasKey("Temporary_") )
        {
            debug_text .= ImeDebugGetProfilerText("Temporary_", 2)
        }
        debug_text .= "`n----------------" debug_level "-"
        if( ImeProfilerHasKey("Assert_") )
        {
            debug_text .= ImeDebugGetProfilerText("Assert_", 2)
        }
    }
    else
    {
        if( ImeProfilerHasKey("Assert_") )
        {
            debug_text .= "`n----------------" debug_level "-"
            debug_text .= ImeDebugGetProfilerText("Assert_", 2)
        }
    }

    return debug_text
}
