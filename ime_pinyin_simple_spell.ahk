;*******************************************************************************
; 超级简拼
;
PinyinResultInsertSimpleSpell(ByRef DB, ByRef search_result, separate_single_char)
{
    local
    global history_field_array

    if( separate_single_char )
    {
        PinyinUpdateKey(DB, separate_single_char, false, true, 8)
        loop % list_len := history_field_array[separate_single_char].Length()
        {
            search_result.InsertAt(1, CopyObj(history_field_array[separate_single_char, list_len+1-A_Index]))
        }
    }
    return
}
