PinyinHistoryClear()
{
    global history_field_array := []
}

PinyinHistoryHasResult(splitted_string)
{
    global history_field_array
    return history_field_array[splitted_string, 1, 2] != ""
}

PinyinHistoryHasKey(splitted_string)
{
    global history_field_array
    ImeProfilerBegin(14)
    ImeProfilerEnd(14, "`n  - [" splitted_string "]: " history_field_array.HasKey(splitted_string))
    return history_field_array.HasKey(splitted_string)
}

PinyinHistoryUpdateKey(splitted_string, auto_comple:=false, limit_num:=100)
{
    global history_field_array
    if( !PinyinHistoryHasKey(splitted_string) || history_field_array[splitted_string].Length()==2 && history_field_array[splitted_string,2,2]=="" )
    {
        history_field_array[splitted_string] := PinyinSqlGetResult(splitted_string, auto_comple, limit_num)
    }
}

PinyinHistoryGetWords(splitted_string)
{
    global history_field_array
    return history_field_array[splitted_string]
}

PinyinHistoryGetResultLength(splitted_string)
{
    global history_field_array
    return history_field_array[splitted_string].Length()
}

PinyinResultPushHistory(ByRef search_result, splitted_string, max_num := 100)
{
    global history_field_array
    loop % Min(history_field_array[splitted_string].Length(), max_num)
    {
        search_result.Push(CopyObj(history_field_array[splitted_string, A_Index]))
    }
}

PinyinResultInsertAtHistory(ByRef search_result, splitted_string, insert_at := 1, max_num := 100)
{
    local
    global history_field_array
    list_len := history_field_array[splitted_string].Length()
    loop % Min(list_len, max_num)
    {
        search_result.InsertAt(insert_at, CopyObj(history_field_array[splitted_string, list_len+1-A_Index]))
    }
}
