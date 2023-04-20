TranslatorResultFilterSingleWord(ByRef translate_result)
{
    local
    ImeProfilerBegin(37)

    index := 1
    loop % translate_result.Length()
    {
        if( translate_result[index, 5] > 1 )
        {
            translate_result.RemoveAt(index)
        }
        else
        {
            index += 1
        }
    }

    ImeProfilerEnd(37)
}

TranslatorResultFilterZeroWeight(ByRef translate_result)
{
    local
    profile_text := ImeProfilerBegin(35)

    index := 1
    loop % translate_result.Length()
    {
        weight := translate_result[index, 3]
        if( weight<=0 )
        {
            if( index == 1 ){
                break
            }
            translate_result.RemoveAt(index, translate_result.Length() - index + 1)
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
