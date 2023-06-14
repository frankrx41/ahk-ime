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

    debug_text .= "`n" . name . "*" ImeProfilerGetCount(name) ":"
    debug_text .= "(" ImeProfilerGetTotalTick(name) ") "
    profile_text := ImeProfilerGetProfileText(name)

    if( debug_level == 2 ) {
        debug_text .= profile_text
    }

    return debug_text
}

ImeDebugGetDisplayText()
{
    local
    debug_text := ""
    if( ImeDebugGet() )
    {
        ; Comment out the debug info you don't want
        ; If you want add new debug info, do follow:
        ; ```
        ;   ImeProfilerBegin()
        ;   ImeProfilerEnd(profile_text)
        ; ```
        ; See ime_profiler.ahk for detail.

        ; name_list := ImeProfilerGetAllNameList()
        name_list := ["SelectorFindGraceResultIndex_", "SelectorCheckTotalWeight_"]

        debug_level := ImeDebugGet()
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
        debug_text .= "`n----------------" ImeDebugGet() "-"
        if( ImeProfilerHasKey("Assert_") )
        {
            debug_text .= ImeDebugGetProfilerText("Assert_", 2)
        }
    }
    else
    {
        if( ImeProfilerHasKey("Assert_") )
        {
            debug_text .= "`n----------------" ImeDebugGet() "-"
            debug_text .= ImeDebugGetProfilerText("Assert_", 2)
        }
    }

    return debug_text
}
