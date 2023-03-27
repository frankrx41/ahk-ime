;*******************************************************************************
; 超级简拼
;
; "wo3xi3huanni" -> "w%'o%3x%'i%3h%'u%'a%'n%'n%'i%"
; "wo3ai4ni" -> "w%'o%3a%'i%4'n%'i%"
SplitWordGetSimpleSpell(input_string)
{
    input_string := RegExReplace(input_string, "([a-z])(?=[^'\d])", "$1'")
    input_string := RTrim(input_string, "'")
    input_string := StrReplace(input_string, " ")
    input_string := RegExReplace(input_string, "(['\d])", "%$1")
    if( InStr("12345", SubStr(input_string, 0, 1)) ) {
        input_string .= ""
    } else {
        input_string .= "%"
    }
    return input_string
}

; Not include "i" "u" "v"
SeparateStringHasSound(separate_string)
{
    return !RegExMatch(separate_string, "[iuv]%")
}

SeparateStringShouldProcess(separate_string, ime_input_split_trim)
{
    local
    if( PinyinSqlSimpleKey(separate_string) == PinyinSqlSimpleKey(ime_input_split_trim) )
    {
        return false
    }
    if( !SeparateStringHasSound(separate_string) )
    {
        return false
    }

    str_len := (StrLen(separate_string)+1)/3
    ; Do simple spell: yeb mla
    if( str_len == 3 ){
        char_1 := SubStr(separate_string, 1, 1)
        char_2 := SubStr(separate_string, 4, 1)
        char_3 := SubStr(separate_string, 7, 1)
        if( !IsCompletePinyin(char_1, char_2) && !IsCompletePinyin(char_2, char_3) )
        {
            return true
        }
    }
    if( str_len < 4 || str_len > 8 )
    {
        return false
    }
    return true
}

PinyinResultInsertSimpleSpell(ByRef DB, ByRef search_result, ime_input_split_trim)
{
    local
    global history_field_array
    global tooltip_debug

    separate_string := SplitWordGetSimpleSpell(ime_input_split_trim)
    if( SeparateStringShouldProcess(separate_string, ime_input_split_trim) )
    {
        PinyinHistoryUpdateKey(DB, separate_string)
        PinyinResultInsertAtHistory(search_result, separate_string, 1)
        tooltip_debug[8] .= """" separate_string """->(" PinyinHistoryGetResultLength(separate_string) ")"
    }
    return
}
