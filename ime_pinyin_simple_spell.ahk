;*******************************************************************************
; 超级简拼
;
; "wo3xi3huanni" -> "w'o3x'i3h'u'a'n'n'i"
GetSimpleSpellString(input_string)
{
    input_string := StrReplace(input_string,"%")
    input_string := RegExReplace(input_string,"([^'\d])","$1'")
    input_string := StrReplace(input_string,"''","'")
    input_string := RegExReplace(input_string,"'(\d)","$1")
    return input_string
}

PinyinResultInsertSimpleSpell(ByRef DB, ByRef search_result, ime_input_split_trim)
{
    local
    global history_field_array
    global tooltip_debug

    separate_single_char := GetSimpleSpellString(ime_input_split_trim)
    str_len := StrLen(separate_single_char)/2
    if( str_len >= 4 && str_len <= 8 && ime_input_split_trim != separate_single_char )
    {
        PinyinUpdateKey(DB, separate_single_char, 8)
        list_len := history_field_array[separate_single_char].Length()
        loop % list_len
        {
            search_result.InsertAt(1, CopyObj(history_field_array[separate_single_char, list_len+1-A_Index]))
        }
        tooltip_debug[8] .= """" separate_single_char """->(" list_len ")"
    }
    return
}
