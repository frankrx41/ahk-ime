PinyinResultFilterSingleWord(ByRef search_result)
{
    local
    ImeProfilerBegin(27)

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

    ImeProfilerEnd(27)
}
