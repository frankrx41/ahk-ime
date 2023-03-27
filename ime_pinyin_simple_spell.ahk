;*******************************************************************************
; 超级简拼
;
; "wo3xi3huanni" -> "w%'o%3x%'i%3h%'u%'a%'n%'n%'i%"
; "wo3ai4ni" -> "w%'o%3a%'i%4'n%'i%"
SplitWordGetSimpleSpell(input_string)
{
    input_string := RegExReplace(input_string, "([a-z])(?=[^%'12345])", "$1'")
    input_string := RegExReplace(input_string, "([^%])(['12345])", "$1%$2")
    return input_string
}

; Not include "i" "u" "v"
SeparateStringHasSound(separate_string)
{
    return !RegExMatch(separate_string, "[iuv]%")
}

SeparateStringShouldProcess(separate_string, input_split)
{
    local
    if( PinyinSqlSimpleKey(separate_string) == PinyinSqlSimpleKey(input_split) )
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

PinyinResultInsertSimpleSpell(ByRef DB, ByRef search_result, input_split)
{
    local
    global history_field_array
    global tooltip_debug

    separate_string := SplitWordGetSimpleSpell(input_split)
    if( SeparateStringShouldProcess(separate_string, input_split) )
    {
        PinyinHistoryUpdateKey(DB, separate_string, true)
        PinyinResultInsertAtHistory(search_result, separate_string, 1)
        tooltip_debug[8] .= """" separate_string """->(" PinyinHistoryGetResultLength(separate_string) ")"
    }
    return
}
