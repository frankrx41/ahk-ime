;*******************************************************************************
; Return initials and update parsing_length
PinyinSplitterParseInitials(input_str, ByRef parsing_length, covert_func:="NormalToNormal")
{
    local
    parsing_length := 1
    initials := SubStr(input_str, 1, 1)
    initials := Func(covert_func).Call(initials, A_Index)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, 2, 1)=="h") ){
        parsing_length += 1
        initials .= "h"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, 2, 1)=="?") ){
        parsing_length += 1
        initials .= "?"
    }
    Assert(Asc(initials) == Asc(Format("{:L}", initials)))
    return initials
}

IsNeedSplit(check_mark)
{
    return IsInitials(check_mark) || IsInitialsAnyMark(check_mark) || IsRepeatMark(check_mark)
}
