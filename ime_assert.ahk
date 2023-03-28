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

Assert(bool, str:="", deepness:=5, show_msg:=false)
{
    local
    if( !bool )
    {
        git_hash := RTrim(CmdRet("git rev-parse --short HEAD"), "`n")
        time_string = %A_YYYY%-%A_MM%-%A_DD% %A_Hour%:%A_Min%:%A_Sec%
        deepness := Max(1, deepness)

        debug_info := time_string " [" git_hash "]"
        debug_info .= (deepness == 1) ? " " : "`n"
        debug_info .= CallStack(deepness)
        debug_info .= " """ str """`n"

        FileAppend, %debug_info%, .\debug.log
        if( show_msg ){
            Msgbox, % debug_info
        }
        ImeProfilerSetDebugInfo(4, "Assert: " CallStack(1) ": """ str """")
    }
}
