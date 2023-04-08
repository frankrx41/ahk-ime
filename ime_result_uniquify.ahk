TranslatorResultUniquify(ByRef translate_result)
{
    local
    ImeProfilerBegin(39)
    store_result := {}

    begin_tick := A_TickCount
    index := 1
    loop % translate_result.Length()
    {
        word_value := translate_result[index, 2]
        if( store_result.HasKey(word_value) )
        {
            translate_result.RemoveAt(index)
        }
        else
        {
            store_result[word_value] := 1
            index += 1
        }
    }
    ImeProfilerEnd(39)
}
