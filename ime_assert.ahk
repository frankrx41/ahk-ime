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

Assert(bool, str:="", show_msgbox:=false)
{
    local
    if( !bool )
    {
        git_hash := RTrim(CmdRet("git rev-parse --short HEAD"), "`n")
        time_string = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%

        debug_info := time_string " [" git_hash "]`n"
        debug_info .= CallStack()
        debug_info .= " """ str """`n"

        FileAppend, %debug_info%, .\debug.log
        if( show_msgbox ){
            Msgbox, 18, Assert, % debug_info "`n" """" str """"
        }
        call_stack_str := RegExReplace(CallStack(1), "^.*\\")
        ImeProfilerBegin(4)
        ImeProfilerEnd(4, "`n  - " call_stack_str " """ str """")
    }
}
