TranslatorHistoryClear()
{
    global translator_history_result := []
}

TranslatorHistoryHasResult(splitted_string)
{
    ; TODO: what is different between `TranslatorHistoryHasKey`?
    global translator_history_result
    return translator_history_result[splitted_string, 1, 2] != ""
}

TranslatorHistoryHasKey(splitted_string)
{
    global translator_history_result
    return translator_history_result.HasKey(splitted_string)
}

TranslatorHistoryUpdateKey(splitted_string, auto_comple:=false, limit_num:=100)
{
    global translator_history_result
    if( !TranslatorHistoryHasKey(splitted_string) || translator_history_result[splitted_string].Length()==2 && translator_history_result[splitted_string,2,2]=="" )
    {
        translator_history_result[splitted_string] := PinyinSqlGetResult(splitted_string, auto_comple, limit_num)
    }
}

TranslatorHistoryGetKeyResultLength(splitted_string)
{
    global translator_history_result
    return translator_history_result[splitted_string].Length()
}

TranslatorHistoryPushResult(ByRef search_result, splitted_string, max_num := 100)
{
    global translator_history_result
    loop % Min(translator_history_result[splitted_string].Length(), max_num)
    {
        search_result.Push(CopyObj(translator_history_result[splitted_string, A_Index]))
    }
}

TranslatorHistoryInsertResult(ByRef search_result, splitted_string, insert_at := 1, max_num := 100)
{
    local
    global translator_history_result
    list_len := translator_history_result[splitted_string].Length()
    loop % Min(list_len, max_num)
    {
        search_result.InsertAt(insert_at, CopyObj(translator_history_result[splitted_string, list_len+1-A_Index]))
    }
}
