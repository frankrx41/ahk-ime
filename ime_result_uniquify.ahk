PinyinResultUniquify(ByRef search_result)
{
    local
    global tooltip_debug
    store_result := {}

    begin_tick := A_TickCount
    index := 1
    loop % search_result.Length()
    {
        word_value := search_result[index, 2]
        if( store_result.HasKey(word_value) )
        {
            search_result.RemoveAt(index)
        }
        else
        {
            store_result[word_value] := 1
            index += 1
        }
    }
    tooltip_debug[28] := "(" A_TickCount - begin_tick ")"
}
