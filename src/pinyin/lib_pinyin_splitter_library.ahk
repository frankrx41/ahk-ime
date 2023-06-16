;*******************************************************************************
; Static
PinyinSplitterGetTone(input_str, initials, vowels, ByRef index)
{
    local
    strlen := StrLen(input_str)
    tone := SubStr(input_str, index, 1)
    if( IsTone(tone) ) {
        index += 1
        if( IsEmptyTone(tone) ){
            tone := 0
        }
    } else {
        tone := 0
    }
    return tone
}

; Return 012345, marks tone
; Update `test_index`
PinyinSplitterGetTone2(input_str, ByRef test_index)
{
    local
    test_index := 0
    tone := SubStr(input_str, 1, 1)
    if( IsEmptyTone(tone) )
    {
        test_index := 1
        tone := 0
    } else
    if( IsTone(tone) )
    {
        test_index := 1
    } else
    {
        tone := 0
    }
    return tone
}

;*******************************************************************************
;
PinyinSplitterGetInitials(input_str, initials, ByRef index, covert_func:="NormalToNormal")
{
    local
    index += 1
    
    initials := Func(covert_func).Call(initials, 0)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}

PinyinSplitterGetInitials2(input_str, ByRef test_index)
{
    local
    test_index := 1
    initials := SubStr(input_str, 1, 1)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, 2, 1)=="h") ){
        test_index += 1
        initials .= "h"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, 2, 1)=="?") ){
        test_index += 1
        initials .= "?"
    }
    Assert(Asc(initials) == Asc(Format("{:L}", initials)))
    return initials
}

IsNeedSplit(check_mark)
{
    return IsInitials(check_mark) || IsInitialsAnyMark(check_mark) || IsRepeatMark(check_mark)
}

PinyinSplitterGetRadical(input_string, ByRef test_index)
{
    radical := GetRadical(input_string)
    test_index := StrLen(radical)
    return radical
}
