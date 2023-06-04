;*******************************************************************************
; Static
PinyinSplitterGetTone(input_str, initials, vowels, ByRef index)
{
    local
    strlen := StrLen(input_str)
    tone := SubStr(input_str, index, 1)
    if( IsTone(tone) ) {
        index += 1
        if( tone == " " || tone == "'" ){
            tone := 0
        }
    } else {
        tone := 0
    }
    return tone
}
