;*******************************************************************************
; Assert
; Process will auto store failed assert in "".\debug.log"
;*******************************************************************************
;
Assert(bool, debug_msg:="", debug_level:="log")
{
    local
    static assert_ignore_list   := {}
    static disable_tick         := 0
    static in_msgbox            := false
    static 
    if( IsDebugVersion() && !bool )
    {
        mark_key := GetCallStackText(1)
        if( !assert_ignore_list.HasKey(mark_key) )
        {
            time_string = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%
            if( !debug_msg )
            {
                exception_curr := Exception("", -1)
                FileReadLine, line, % exception_curr.file, % exception_curr.line
                debug_msg := RegExReplace(line, "\s+" A_ThisFunc "(.*)", "$1")
            }
            git_hash    := GetGitHash()
            debug_info  := time_string " [" git_hash "] (" ImeInputterGetDisplayDebugString() ")`n"
            debug_info  .= GetCallStackText(4) " """ debug_msg """`n"
            FileAppend, %debug_info%, .\debug.log

            if( debug_level == "msgbox" && A_TickCount - disable_tick > 6000 && !in_msgbox ){
                in_msgbox := true
                Msgbox, 18, Assert, % debug_info "---`n(" ImeInputterGetDisplayDebugString(true) "):`n" debug_msg "`n---`nAbout:`tIgnore all assert for 1 minute`nRetry:`tAlways ignore this assert`nIgnore:`tIgnore this assert once"
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
            ImeProfilerDebug(CallerName(0) " """ debug_msg """")
        }
    }
}

; https://www.autohotkey.com/board/topic/76062-ahk-l-how-to-get-callstack-solution/
GetCallStackText(deepness := 5, print_lines := 0)
{
    stack := ""
    line_file := A_LineFile
    loop % deepness
    {
        lvl := -2 - deepness + A_Index
        line_numeber := A_LineNumber
        exception_curr := Exception("", lvl)
        if( exception_curr.Line == line_numeber + 1 && exception_curr.File == line_file )
        {
            continue
        }
        exception_prev := Exception("", lvl - 1)
        stack .= "`n" . exception_curr.file " (" exception_curr.line ") : " exception_prev.What
        if( print_lines )
        {
            FileReadLine, line, % exception_curr.file, % exception_curr.line
            stack .=  "`n  - " LTrim(line)
        }
    }
    return LTrim(stack, "`n")
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
