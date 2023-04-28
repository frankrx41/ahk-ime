TranslatorHistoryClear()
{
    global translator_history_result := []
}

;*******************************************************************************
; Static
TranslatorHistoryHasKey(splitted_string)
{
    global translator_history_result
    return translator_history_result.HasKey(splitted_string)
}

GetSplittedStringKey(splitted_string, auto_comple)
{
    if( auto_comple ){
        splitted_key := splitted_string "*"
    } else {
        splitted_key := splitted_string
    }
    return splitted_key
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
TranslatorHistoryUpdateKey(splitted_string, auto_comple, word_length, limit_num:=100)
{
    global translator_history_result
    splitted_key := GetSplittedStringKey(splitted_string, auto_comple)
    if( !TranslatorHistoryHasKey(splitted_string) )
    {
        translator_history_result[splitted_key] := PinyinSqlGetResult(splitted_string, auto_comple, limit_num)
        loop % translator_history_result[splitted_key].Length() {
            translator_history_result[splitted_key, A_Index, 5] := word_length
        }
        if( word_length == 1 )
        {
            Assert(translator_history_result[splitted_key].Length() > 0, splitted_string " has no result!", true)
        }
    }
}

;*******************************************************************************
; Update `translate_result`
TranslatorHistoryPushResult(ByRef translate_result, splitted_string, auto_comple:=false, max_num := 100, modify_weight := 0)
{
    global translator_history_result
    splitted_key := GetSplittedStringKey(splitted_string, auto_comple)
    loop % Min(translator_history_result[splitted_key].Length(), max_num)
    {
        single_result := CopyObj(translator_history_result[splitted_key, A_Index])
        if( modify_weight ) {
            TranslatorSingleResultSetWeight(single_result, TranslatorSingleResultGetWeight(single_result) + modify_weight)
        }
        translate_result.Push(single_result)
    }
}

TranslatorHistoryInsertResultAt(ByRef translate_result, splitted_string, auto_comple:=false, insert_at := 1, max_num := 100)
{
    local
    global translator_history_result
    splitted_key := GetSplittedStringKey(splitted_string, auto_comple)
    list_len := translator_history_result[splitted_key].Length()
    loop_cnt := Min(list_len, max_num)
    loop % loop_cnt
    {
        translate_result.InsertAt(insert_at, CopyObj(translator_history_result[splitted_key, loop_cnt+1-A_Index]))
    }
}
