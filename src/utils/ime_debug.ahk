;*******************************************************************************
; This file ONLY used for debug
;
; Please stop track this file
; You can use the following command:
;   - To track: `git update-index --no-skip-worktree src\utils\ime_debug.ahk`
;   - To skip:  `git update-index --skip-worktree src\utils\ime_debug.ahk`
;*******************************************************************************
; Static
ImeDebugGetProfilerText(name)
{
    local
    debug_text := ""

    debug_text .= "`n" . name . "*" ImeProfilerGetCount(name) ":"
    debug_text .= "(" ImeProfilerGetTotalTick(name) ") "
    profile_text := ImeProfilerGetProfileText(name)

    if( name == "Assert_" ) {
        debug_text .= profile_text
    } else {
        ; Show full info
        if( ImeDebugGet() == 2 ) {
            debug_text .= profile_text
        }
    }
    return debug_text
}

ImeDebugGetDisplayText()
{
    local
    debug_text := ""
    if( !ImeDebugGet() )
    {
        return debug_text
    }

    ; Comment out the debug info you don't want
    ; If you want add new debug info, do follow:
    ; ```
    ;   ImeProfilerBegin()
    ;   ImeProfilerEnd(profile_text)
    ; ```
    ; See ime_profiler.ahk for detail.

    ; name_list := ImeProfilerGetAllNameList()
    name_list := ["SelectorFindGraceResultIndex_", "SelectorCheckTotalWeight_"]

    for index, element in name_list
    {
        if( ImeProfilerHasKey(element) )
        {
            debug_text .= ImeDebugGetProfilerText(element)
            ; debug_text .= element "`n" ImeDebugGetProfilerText(element) "`n"
        }
    }

    if( ImeProfilerHasKey("Temporary_") )
    {
        debug_text .= ImeDebugGetProfilerText("Temporary_")
    }
    debug_text .= "`n----------------" ImeDebugGet() "-"
    if( ImeProfilerHasKey("Assert_") )
    {
        debug_text .= ImeDebugGetProfilerText("Assert_")
    }

    return debug_text
}
