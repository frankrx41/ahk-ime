ImeTranslatorHistoryInitialize()
{
    global translator_history_normal_result         ; See lib_translator_result.ahk
    global translator_history_zero_weight_result
    ImeTranslatorHistoryClear()
}

ImeTranslatorHistoryClear()
{
    global translator_history_normal_result := []
    global translator_history_zero_weight_result := []
    ImeTranslatorDynamicClear()
}

ImeTranslatorHistoryHasResult(splitted_string)
{
    global translator_history_normal_result
    return translator_history_normal_result[splitted_string].Length() > 0
}

;*******************************************************************************
;
; translator_history_normal_result["lao0shi0"] =
; [
;   [1]: ["lao3shi1", "老师", "26995", "", 2]
;   [2]: ["lao3shi4", "老是", "25921", "", 2]
;   [3]: ["lao3shi2", "老实", "25877", "", 2]
;   ...
; ]
ImeTranslatorHistoryUpdateKey(splitted_string)
{
    local
    global translator_history_normal_result
    global translator_history_zero_weight_result

    if( !translator_history_normal_result.HasKey(splitted_string) )
    {
        translator_history_normal_result[splitted_string]       := PinyinSqlGetResult(splitted_string, false, 0)
        translator_history_zero_weight_result[splitted_string]  := PinyinSqlGetResult(splitted_string, true, 0)
    }
}

ImeTranslatorHistoryGetResultWord(splitted_string, word_class:="")
{
    global translator_history_normal_result
    loop
    {
        word := TranslatorResultGetWord(translator_history_normal_result[splitted_string, A_Index])
        if( word_class == "" ){
            return word
        }
    }
    return ""
}

;*******************************************************************************
;
ImeTranslatorHistoryGetTopWeightList(splitted_string)
{
    global translator_history_normal_result
    return ImeTranslatorDynamicUpdatePosition(splitted_string, translator_history_normal_result[splitted_string])
}

;*******************************************************************************
; Update `translate_result`
ImeTranslatorHistoryPushResult(ByRef translate_result_list, splitted_string, word_length, max_num := 100)
{
    local
    translator_list := ImeTranslatorHistoryGetTopWeightList(splitted_string)
    if( max_num == 0 )
    {
        max_num := translator_list.Length()
    }

    loop % Min(translator_list.Length(), max_num)
    {
        single_result := translator_list[A_Index]
        TranslatorResultSetWordLength(single_result, word_length)
        translate_result_list.Push(single_result)
    }
}

ImeTranslatorHistoryPushZeroWeightResult(ByRef translate_result_list, splitted_string, word_length, max_num := 100)
{
    local
    global translator_history_zero_weight_result
    translator_list := CopyObj(translator_history_zero_weight_result[splitted_string])
    if( max_num == 0 )
    {
        max_num := translator_list.Length()
    }

    loop % Min(translator_list.Length(), max_num)
    {
        single_result := translator_list[A_Index]
        TranslatorResultSetWordLength(single_result, word_length)
        translate_result_list.Push(single_result)
    }
}

ImeTranslatorHistoryInsertResultAt(ByRef translate_result_list, splitted_string, word_length, insert_at := 1, max_num := 100)
{
    local
    translator_list := ImeTranslatorHistoryGetTopWeightList(splitted_string)
    list_len := translator_list.Length()
    loop_cnt := Min(list_len, max_num)
    loop % loop_cnt
    {
        index := loop_cnt+1-A_Index
        single_result := translator_list[index]
        TranslatorResultSetWordLength(single_result, word_length)
        translate_result_list.InsertAt(insert_at, single_result)
    }
}
