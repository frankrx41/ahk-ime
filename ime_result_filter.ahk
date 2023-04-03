TranslatorResultFilterSingleWord(ByRef search_result)
{
    local
    ImeProfilerBegin(37)

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

    ImeProfilerEnd(37)
}

TranslatorResultFilterZeroWeight(ByRef search_result)
{
    local
    profile_text := ImeProfilerBegin(35)

    index := 1
    loop % search_result.Length()
    {
        weight := search_result[index, 3]
        if( weight<=0 )
        {
            if( index == 1 ){
                break
            }
            search_result.RemoveAt(index, search_result.Length() - index + 1)
            break
        }
        else
        {
            index += 1
        }
    }
    ImeProfilerEnd(35, profile_text . "`n  - Remove at: " index)
    return
}
