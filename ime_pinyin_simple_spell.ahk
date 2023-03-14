
PinyinSimpleSpell(ByRef DB, ByRef search_result, srf_all_Input, enable)
{
    global history_field_array
    scheme := "pinyin"

    single_char_spell := Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'")
    if( enable && (srf_all_Input~="^[^']{4,8}$") && !PinyinHasKey(single_char_spell) )
    {
        history_field_array[single_char_spell] := Get_jianpin(DB, scheme, "'" single_char_spell "'", "", 0, 8, true)
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
