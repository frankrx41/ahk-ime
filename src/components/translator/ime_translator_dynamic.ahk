ImeTranslatorDynamicClear()
{
    ; {[0]: total_index, "bu4shou3": [[0]:1, "部首", "不守"] }
    global translator_history_weight := {}
    translator_history_weight[0] := 0
}

;*******************************************************************************
;
ImeTranslatorDynamicUpdateWeight(splitted_string, translator_list)
{
    local
    global translator_history_weight

    ImeProfilerBegin(17)

    profile_text := ""
    additional_translator_result_list := []
    first_weight := TranslatorResultGetWeight(translator_list[1])

    for key, value in translator_history_weight
    {
        if( IsPinyinSoundLike(splitted_string, key) )
        {
            base_weight := value[0] + first_weight
            profile_text .= "`n  - " splitted_string ", " key ", " base_weight ": "
            loop, % value.Length()
            {
                value_word := value[A_Index]
                value_weight := base_weight + A_Index
                profile_text .= value_word " "
                loop, % translator_list.Length()
                {
                    translator_result := translator_list[A_Index]
                    if( TranslatorResultGetWord(translator_result) == value_word ){
                        translator_result_top := TranslatorResultMakeTop(translator_result, value_weight)
                        translator_list.RemoveAt(A_Index, 1)
                        additional_translator_result_list.Push(translator_result_top)
                        break
                    }
                }
            }
        }
    }

    additional_translator_result_list := TranslatorResultListSortByWeight(additional_translator_result_list)

    loop, % additional_translator_result_list.Length()
    {
        translator_result := additional_translator_result_list[A_Index]
        translator_list.InsertAt(A_Index, translator_result)
    }

    ImeProfilerEnd(17, profile_text)

    return translator_list
}

;*******************************************************************************
;
ImeTranslatorDynamicMark(pinyin, word)
{
    local
    global translator_history_weight

    Assert(pinyin)

    translator_history_weight[0] += 1
    if( !translator_history_weight.HasKey(pinyin) ){
        translator_history_weight[pinyin] := []
        translator_history_weight[pinyin, 0] := 0
    }
    loop, % translator_history_weight[pinyin].Length() {
        if( translator_history_weight[pinyin, A_Index] == word ){
            translator_history_weight[pinyin].RemoveAt(A_Index, 1)
            break
        }
    }
    translator_history_weight[pinyin].Push(word)
    translator_history_weight[pinyin, 0] := translator_history_weight[0]
}
