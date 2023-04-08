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

;*******************************************************************************
;
; translator_history_result["lao0shi0"] =
; [
;   [1]: ["lao3shi1", "老师", "26995", "", 2]
;   [2]: ["lao3shi4", "老是", "25921", "", 2]
;   [3]: ["lao3shi2", "老实", "25877", "", 2]
;   ...
; ]
TranslatorHistoryUpdateKey(splitted_string, word_length, auto_comple:=false, limit_num:=100)
{
    global translator_history_result
    if( !TranslatorHistoryHasKey(splitted_string) )
    {
        translator_history_result[splitted_string] := PinyinSqlGetResult(splitted_string, auto_comple, limit_num)
        loop % translator_history_result[splitted_string].Length() {
            translator_history_result[splitted_string, A_Index, 5] := word_length
        }
        if( word_length == 1 )
        {
            Assert(translator_history_result[splitted_string].Length() > 0, splitted_string " has no result!", true)
        }
    }
}

;*******************************************************************************
; Update `search_result`
TranslatorHistoryPushResult(ByRef search_result, splitted_string, max_num := 100, modify_weight := 0)
{
    global translator_history_result
    loop % Min(translator_history_result[splitted_string].Length(), max_num)
    {
        single_result := CopyObj(translator_history_result[splitted_string, A_Index])
        if( modify_weight ) {
            SingleResultSetWeight(single_result, SingleResultGetWeight(single_result) + modify_weight)
        }
        search_result.Push(single_result)
    }
}

TranslatorHistoryInsertResult(ByRef search_result, splitted_string, insert_at := 1, max_num := 100)
{
    local
    global translator_history_result
    list_len := translator_history_result[splitted_string].Length()
    loop_cnt := Min(list_len, max_num)
    loop % loop_cnt
    {
        search_result.InsertAt(insert_at, CopyObj(translator_history_result[splitted_string, loop_cnt+1-A_Index]))
    }
}
