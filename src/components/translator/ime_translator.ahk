TranslatorHistoryInitialize()
{
    global translator_history_result    ; See ime_translator_result.ahk
    TranslatorHistoryClear()
}

TranslatorHistoryClear()
{
    global translator_history_result := []
    TranslatorDynamicClear()
}

TranslatorHistoryHasResult(splitted_string)
{
    global translator_history_result
    return translator_history_result[splitted_string].Length() > 0
}

;*******************************************************************************
; Static
TranslatorHistoryHasKey(splitted_string)
{
    global translator_history_result
    return translator_history_result.HasKey(splitted_string)
}

;*******************************************************************************
;
; translator_history_result["lao0shi0"] =
; [
;   [1]: ["lao3shi1", "老师", "26995", "", 2]
;   [2]: ["lao3shi4", "老是", "25921", "", 2]
;   [3]: ["lao3shi2", "老实", "25877", "", 2]
;   ...
; ]
TranslatorHistoryUpdateKey(splitted_string, limit_num:=100)
{
    local
    global translator_history_result

    if( !TranslatorHistoryHasKey(splitted_string) )
    {
        translator_history_result[splitted_string] := PinyinSqlGetResult(splitted_string, limit_num)
    }
}

TranslatorHistoryGetResultWord(splitted_string, word_class:="")
{
    global translator_history_result
    loop
    {
        word := TranslatorResultGetWord(translator_history_result[splitted_string, A_Index])
        if( word_class == "" ){
            return word
        }
    }
    return ""
}

;*******************************************************************************
;
TranslatorHistoryGetTopWeightList(splitted_string)
{
    global translator_history_result
    global translator_history_weight

    ImeProfilerBegin(17)
    profile_text := ""
    translator_list := CopyObj(translator_history_result[splitted_string])
    additional_translator_result_list := []
    first_weight := TranslatorResultGetWeight(translator_list[1])

    for key, value in translator_history_weight {
        if( PinyinCheckMatch(splitted_string, key) )
        {
            base_weight := value[0] + first_weight
            profile_text .= "`n  - " key ", " base_weight ": "
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
; Update `translate_result`
TranslatorHistoryPushResult(ByRef translate_result_list, splitted_string, max_num := 100, modify_weight := 0)
{
    translator_list := TranslatorHistoryGetTopWeightList(splitted_string)
    loop % Min(translator_list.Length(), max_num)
    {
        single_result := translator_list[A_Index]
        translate_result_list.Push(single_result)
    }
}

TranslatorHistoryInsertResultAt(ByRef translate_result_list, splitted_string, insert_at := 1, max_num := 100)
{
    local
    translator_list := TranslatorHistoryGetTopWeightList(splitted_string)
    list_len := translator_list.Length()
    loop_cnt := Min(list_len, max_num)
    loop % loop_cnt
    {
        index := loop_cnt+1-A_Index
        single_result := translator_list[index]
        translate_result_list.InsertAt(insert_at, single_result)
    }
}
