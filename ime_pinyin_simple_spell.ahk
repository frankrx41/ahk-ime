
PinyinSimpleSpell(ByRef DB, ByRef search_result, srf_all_Input)
{
    global history_field_array

    ; "woxihuanni" -> "w'o'x'i'h'u'a'n'n'i"
    single_char_spell := Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'")
    if( srf_all_Input~="^[^']{4,8}$" )
    {
        PinyinUpdateKey(DB, single_char_spell, false, true, 8)
    }

    if( single_char_spell )
    {
        loop % list_len := history_field_array[single_char_spell].Length()
        {
            search_result.InsertAt(1, CopyObj(history_field_array[single_char_spell, list_len+1-A_Index]))
        }
    }
    return
}
