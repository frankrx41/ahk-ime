;*******************************************************************************
; Return 012345, marks tone
; Update `parsing_length`
PinyinSplitterParseTone(input_str, ByRef parsing_length)
{
    local
    parsing_length := 0
    tone := SubStr(input_str, 1, 1)
    ; We not check the tone is illegal or not
    ; So if illegal, it will show the origin input
    ; if( IsIllegalTone(initials, vowels, tone) ) {
    ;     tone := 0
    ; }
    ; else
    if( IsEmptyTone(tone) ) {
        parsing_length := 1
        tone := 0
    }
    else
    if( IsTone(tone) )
    {
        parsing_length := 1
    }
    else
    {
        tone := 0
    }
    return tone
}

;*******************************************************************************
; Return initials and update parsing_length
PinyinSplitterParseInitials(input_str, ByRef parsing_length)
{
    local
    parsing_length := 1
    initials := SubStr(input_str, 1, 1)
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

;*******************************************************************************
;
PinyinSplitterParseRadical(input_string, ByRef parsing_length)
{
    radical := GetRadical(input_string)
    parsing_length := StrLen(radical)
    return radical
}

;*******************************************************************************
;
PinyinSplitterUpdateHopeLength(ByRef splitter_list, ByRef hope_length_list)
{
    local

    loop, % splitter_list.Length()
    {
        splitter_result := splitter_list[A_Index]
        need_translate  := SplitterResultNeedTranslate(splitter_result)
        if( need_translate ){
            if( hope_length_list[1] == 0 ){
                hope_length_list.RemoveAt(1)
            }
            hope_length := hope_length_list[1]
            hope_length_list[1] -= 1
        } else {
            hope_length := 1
        }
        SplitterResultSetHopeLength(splitter_result, hope_length)
    }
}
