TranslatorResultListFilterSingleWord(ByRef translate_result_list)
{
    local
    ImeProfilerBegin()

    index := 1
    loop % translate_result_list.Length()
    {
        if( TranslatorResultGetWordLength(translate_result_list[index]) > 1 )
        {
            translate_result_list.RemoveAt(index)
        }
        else
        {
            index += 1
        }
    }

    ImeProfilerEnd()
}

TranslatorResultListFilterZeroWeight(ByRef translate_result_list)
{
    local
    ImeProfilerBegin()

    index := 1
    loop % translate_result_list.Length()
    {
        weight := TranslatorResultGetWeight(translate_result_list[index])
        if( weight <= 0 )
        {
            ; If only has 0 weight result, skip
            if( index != 1 ){
                translate_result_list.RemoveAt(index, translate_result_list.Length() - index + 1)
            }
            break
        }
        else
        {
            index += 1
        }
    }
    ImeProfilerEnd("Remove at: " index)
    return
}
