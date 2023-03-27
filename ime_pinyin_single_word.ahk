PinyinResultFilterSingleWord(ByRef search_result)
{
    local
    index := 1
    loop % search_result.Length()
    {
        if( SplitWordGetWordCount(search_result[index, 1]) > 1 )
        {
            search_result.RemoveAt(index)
        }
        else
        {
            index += 1
        }
    }
}
