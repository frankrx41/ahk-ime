TranslatorHistoryInitialize()
{
    global translator_history_result    ; See ime_translator_result.ahk
    global translator_history_weight    ; {[0]: total_index, "bu4shou3": [[0]:1, "部首", "不守"] }
    TranslatorHistoryClear()
}

TranslatorHistoryClear()
{
    global translator_history_result := []
    global translator_history_weight := {}
    translator_history_weight[0] := 0
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
PinyinCheckMatch(check_pinyin, complete_pinyin)
{
    check_pinyin_index := 1
    last_check_char := ""
    loop, Parse, complete_pinyin
    {
        check_char := SubStr(check_pinyin, check_pinyin_index, 1)
        if( IsTone(A_LoopField) ){
            if( check_char == "0" || A_LoopField == check_char ){
                check_pinyin_index += 1
                last_check_char := check_char
            }
            else
            if( A_LoopField != check_char ){
                return false
            }
        }
        else
        if( A_LoopField ){
            if( check_char == "%" || A_LoopField == check_char ) {
                check_pinyin_index += 1
                last_check_char := check_char
            }
            else
            if( A_LoopField != check_char && last_check_char != "%" ){
                return false
            }
        }
    }
    return check_pinyin_index-1 == StrLen(check_pinyin)
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
    global translator_history_weight

    if( !TranslatorHistoryHasKey(splitted_string) )
    {
        translator_history_result[splitted_string] := PinyinSqlGetResult(splitted_string, limit_num)
    }

    ; update weight
    additional_translator_result_list := []
    for key, value in translator_history_weight {
        if( PinyinCheckMatch(splitted_string, key) ) {
            word_length := StrLen(value[1])
            weight := value[0] + TranslatorResultGetWeight(translator_history_result[splitted_string, 1])
            loop, % value.Length() {
                translator_result := TranslatorResultMake(key, value[A_Index], weight+A_Index, "^", word_length)
                additional_translator_result_list.Push(translator_result)
            }
        }
    }
    additional_translator_result_list := TranslatorResultListSortByWeight(additional_translator_result_list)

    loop, % additional_translator_result_list.Length()
    {
        translator_result := additional_translator_result_list[A_Index]
        translator_history_result[splitted_string].InsertAt(A_Index, translator_result)
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
; Update `translate_result`
TranslatorHistoryPushResult(ByRef translate_result_list, splitted_string, max_num := 100, modify_weight := 0)
{
    global translator_history_result
    loop % Min(translator_history_result[splitted_string].Length(), max_num)
    {
        pinyin  := TranslatorResultGetLegacyPinyin(translator_history_result[splitted_string, A_Index])
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
        pinyin  := TranslatorResultGetLegacyPinyin(translator_history_result[splitted_string, A_Index])
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
TranslatorHistoryDynamicWeight(pinyin, word)
{
    local
    global translator_history_result
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
