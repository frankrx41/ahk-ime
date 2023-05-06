TranslatorResultListFilterSingleWord(ByRef translate_result_list)
{
    local
    ImeProfilerBegin(37)

    index := 1
    loop % translate_result_list.Length()
    {
        if( translate_result_list[index, 5] > 1 )
        {
            translate_result_list.RemoveAt(index)
        }
        else
        {
            index += 1
        }
    }

    ImeProfilerEnd(37)
}

TranslatorResultListFilterZeroWeight(ByRef translate_result_list)
{
    local
    profile_text := ImeProfilerBegin(35)

    index := 1
    loop % translate_result_list.Length()
    {
        weight := translate_result_list[index, 3]
        if( weight<=0 )
        {
            if( index == 1 ){
                break
            }
            translate_result_list.RemoveAt(index, translate_result_list.Length() - index + 1)
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
