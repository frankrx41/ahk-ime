PinyinResultFilterSingleWord(ByRef search_result)
{
    local
    global tooltip_debug

    begin_tick := A_TickCount
    index := 1
    loop % search_result.Length()
    {
        if( search_result[index, 5] > 1 )
        {
            search_result.RemoveAt(index)
        }
        else
        {
            index += 1
        }
    }
    tooltip_debug[4] := "(" A_TickCount - begin_tick ")"
}