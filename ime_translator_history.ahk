TranslatorHistoryInitialize()
{
    global translator_history_result    ; See ime_translator_result.ahk
    global translator_history_weight    ; {"单词": 1000, "字": 1000}
    TranslatorHistoryClear()
}

TranslatorHistoryClear()
{
    global translator_history_result := []
    global translator_history_weight := {}
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
TranslatorHistoryUpdateKey(splitted_string, word_length, limit_num:=100)
{
    global translator_history_result
    global translator_history_weight

    if( !TranslatorHistoryHasKey(splitted_string) )
    {
        translator_history_result[splitted_string] := PinyinSqlGetResult(splitted_string, limit_num)
        loop % translator_history_result[splitted_string].Length() {
            ; word length
            translator_history_result[splitted_string, A_Index, 5] := word_length
            ; weight
            word := TranslatorResultGetWord(translator_history_result[splitted_string, A_Index])
            if( translator_history_weight.HasKey(word) ){
                translator_history_result[splitted_string, A_Index, 3] += translator_history_weight[word]
            }
        }
        translator_history_result[splitted_string] := TranslatorResultListSortByWeight(translator_history_result[splitted_string])
    }
}

TranslatorHistoryGetResultWord(splitted_string)
{
    global translator_history_result
    loop
    {
        word := TranslatorResultGetWord(translator_history_result[splitted_string, A_Index])
        if( part_of_speech == "" ){
            return word
        }
    }
    return ""
}

;*******************************************************************************
; Update `translate_result`
TranslatorHistoryPushResult(ByRef translate_result_list, splitted_string, max_num := 100, modify_weight := 0)
{
    global translator_history_result
    loop % Min(translator_history_result[splitted_string].Length(), max_num)
    {
        pinyin  := splitted_string  ; TranslatorResultGetPinyin(translator_history_result[splitted_string, A_Index])
        word    := TranslatorResultGetWord(translator_history_result[splitted_string, A_Index])
        weight  := TranslatorResultGetWeight(translator_history_result[splitted_string, A_Index])
        comment := TranslatorResultGetComment(translator_history_result[splitted_string, A_Index])
        word_length := TranslatorResultGetWordLength(translator_history_result[splitted_string, A_Index])

        single_result := TranslatorResultMake(pinyin, word, weight, comment, word_length + modify_weight)
        translate_result_list.Push(single_result)
    }
}

TranslatorHistoryInsertResultAt(ByRef translate_result_list, splitted_string, insert_at := 1, max_num := 100)
{
    local
    global translator_history_result
    list_len := translator_history_result[splitted_string].Length()
    loop_cnt := Min(list_len, max_num)
    loop % loop_cnt
    {
        index   := loop_cnt+1-A_Index
        pinyin  := splitted_string  ; TranslatorResultGetPinyin(translator_history_result[splitted_string, A_Index])
        word    := TranslatorResultGetWord(translator_history_result[splitted_string, index])
        weight  := TranslatorResultGetWeight(translator_history_result[splitted_string, index])
        comment := TranslatorResultGetComment(translator_history_result[splitted_string, index])
        word_length := TranslatorResultGetWordLength(translator_history_result[splitted_string, index])

        single_result := TranslatorResultMake(pinyin, word, weight, comment, word_length)
        translate_result_list.InsertAt(insert_at, single_result)
    }
}

;*******************************************************************************
;
TranslatorHistoryDynamicUpdate(splitted_string, word)
{
    global translator_history_result
    global translator_history_weight
    if( !translator_history_weight.HasKey(word) ){
        translator_history_weight[word] := 20000
    }

    loop, % translator_history_result[splitted_string].Length()
    {
        if( TranslatorResultGetWord(translator_history_result[splitted_string, A_Index]) == word )
        {
            translator_history_result[splitted_string, A_Index, 3] += translator_history_weight[word]
            break
        }
    }
    translator_history_result[splitted_string] := TranslatorResultListSortByWeight(translator_history_result[splitted_string])
}
