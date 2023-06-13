TranslatorResultListUniquify(ByRef translate_result_list)
{
    local
    ImeProfilerBegin()
    store_result := {}

    begin_tick := A_TickCount
    index := 1
    loop % translate_result_list.Length()
    {
        word_value := TranslatorResultGetWord(translate_result_list[index])
        if( store_result.HasKey(word_value) )
        {
            translate_result_list.RemoveAt(index)
        }
        else
        {
            store_result[word_value] := 1
            index += 1
        }
    }
    ImeProfilerEnd()
}
