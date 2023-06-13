;*******************************************************************************
; Assert
; Process will auto store failed assert in "".\debug.log"
;*******************************************************************************
;
Assert(bool, debug_msg:="", show_msgbox:=true)
{
    static assert_ignore_list := {}
    static disable_tick := 0
    static in_msgbox := false
    local
    if( IsDebugVersion() && !bool )
    {
        git_hash := GetGitHash()
        time_string = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%

        ; debug_msg   := " """ debug_msg """"
        debug_info  := time_string " [" git_hash "] (" ImeInputterGetDisplayDebugString() ")`n"
        debug_info  .= CallStack() " """ debug_msg """`n"

        FileAppend, %debug_info%, .\debug.log
        mark_key := CallStack(1)
        if( show_msgbox && A_TickCount - disable_tick > 6000 && !assert_ignore_list.HasKey(mark_key) && !in_msgbox ){
            in_msgbox := true
            Msgbox, 18, Assert, % debug_info "---`n" ImeInputterGetDisplayDebugString(true) ":`n" debug_msg "`n---`nAbout:`tIgnore all assert for 1 minute`nRetry:`tAlways ignore this assert`nIgnore:`tIgnore this assert once"
            IfMsgBox, Abort
            {
                disable_tick := A_TickCount
            }
            IfMsgBox, Retry
            {
                assert_ignore_list[mark_key] := 1
            }
            in_msgbox := false
        }
        ImeProfilerEnd(4, ImeProfilerBegin(4) "`n  - " CallerName(0) " """ debug_msg """")
    }
}

; https://www.autohotkey.com/board/topic/76062-ahk-l-how-to-get-callstack-solution/
CallStack(deepness = 5, printLines = 0)
{
    stack := ""
    loop % deepness
    {
        lvl := -2 - deepness + A_Index
        oEx := Exception("", lvl)
        oExPrev := Exception("", lvl - 1)
        FileReadLine, line, % oEx.file, % oEx.line
        if(line = "`toEx := Exception("""", lvl)")
            continue
        stack .= (stack ? "`n" : "") oEx.file " (" oEx.line ") : " oExPrev.What (printLines ? "`n" line : "")
    }
    return stack
}

;*******************************************************************************
; return caller function name
; lv == 1 should only work when use in `Assert`
CallerName(lv := 1)
{
    oEx := Exception("", lv-2)
    oExPrev := Exception("", lv-3)
    file_name := RegExReplace(oEx.File, "^.*\\")
    msg := file_name " (" oEx.Line ") : " oExPrev.What
    return msg
}
