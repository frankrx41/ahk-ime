;*******************************************************************************
; This file ONLY used for debug
;
; Please stop track this file
; You can use the following command:
;   - To track: `git update-index --no-skip-worktree src\utils\ime_debug.ahk`
;   - To skip:  `git update-index --skip-worktree src\utils\ime_debug.ahk`
;*******************************************************************************
; Static
ImeDebugGetProfilerText(name, max_length := 100)
{
    local
    debug_tip := ""

    debug_tip .= "`n" . name . "*" ImeProfilerGetCount(name) ":"
    debug_tip .= "(" ImeProfilerGetTotalTick(name) ") "
    debug_info := ImeProfilerGetProfileText(name)
    if( StrLen(debug_info) > max_length ){
        debug_info := SubStr(debug_info, 1, max_length)
        debug_info .= "..."
    }
    if( name == 1 ) {
        debug_tip .= debug_info
    } else {
        ; Show full info
        if( ImeDebugGet() == 2 ) {
            debug_tip .= debug_info
        }
    }
    return debug_tip
}

ImeDebugGetDisplayText()
{
    local
    debug_tip := ""
    if( !ImeDebugGet() )
    {
        return debug_tip
    }

    ; Comment out the debug info you don't want
    ; If you want add new debug info, do follow:
    ; ```
    ;   profile_text := ImeProfilerBegin()
    ;   ImeProfilerEnd(profile_text)
    ; ```
    ; See ime_profiler.ahk for detail.

    ; name_list := ImeProfilerGetAllNameList()
    name_list := ["ImeCandidateUpdateResult_"]

    for index, element in name_list
    {
        debug_tip .= ImeDebugGetProfilerText(element)
        ; debug_tip .= element "`n" ImeDebugGetProfilerText(element) "`n"
    }

    if( ImeProfilerHasKey("Temporary") )
    {
        debug_tip .= ImeDebugGetProfilerText("Temporary", 200)
    }
    if( ImeProfilerHasKey("Assert") )
    {
        debug_tip .= "`n----------------"
        debug_tip .= ImeDebugGetProfilerText("Assert", 200)
    }

    return debug_tip
}
