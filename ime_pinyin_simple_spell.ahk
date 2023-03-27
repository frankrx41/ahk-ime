;*******************************************************************************
; 超级简拼
;
; "wo3xi3huanni" -> "w%'o%3x%'i%3h%'u%'a%'n%'n%'i%"
; "wo3ai4ni" -> "w%'o%3a%'i%4'n%'i%"
GetSimpleSpellString(input_string)
{
    input_string := RegExReplace(input_string, "([a-z])(?=[^'\d])", "$1'")
    input_string := RTrim(input_string, "'")
    input_string := StrReplace(input_string, " ")
    input_string := RegExReplace(input_string, "(['\d])", "%$1")
    return input_string . "%"
}

; Not include "i" "u" "v"
SeparateSingleCharHasSound(separate_single_chars)
{
    return !RegExMatch(separate_single_chars, "[iuv]%")
}

CanMakeSimpleSpell(separate_single_char, ime_input_split_trim)
{
    local
    if( PinyinSqlSimpleKey(separate_single_char) == PinyinSqlSimpleKey(ime_input_split_trim) )
    {
        return false
    }
    if( !SeparateSingleCharHasSound(separate_single_char) )
    {
        return false
    }

    str_len := (StrLen(separate_single_char)+1)/3
    ; Do simple spell: yeb mla
    if( str_len == 3 ){
        char_1 := SubStr(separate_single_char, 1, 1)
        char_2 := SubStr(separate_single_char, 4, 1)
        char_3 := SubStr(separate_single_char, 7, 1)
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

    separate_single_char := GetSimpleSpellString(ime_input_split_trim)
    if( CanMakeSimpleSpell(separate_single_char, ime_input_split_trim) )
    {
        PinyinHistoryUpdateKey(DB, separate_single_char)
        list_len := history_field_array[separate_single_char].Length()
        loop % list_len
        {
            search_result.InsertAt(1, CopyObj(history_field_array[separate_single_char, list_len+1-A_Index]))
        }
        tooltip_debug[8] .= """" separate_single_char """->(" list_len ")"
    }
    return
}
