PinyinHistoryClear()
{
    global history_field_array := []
}

PinyinHistoryHasResult(spilt_word)
{
    global history_field_array
    return history_field_array[spilt_word, 1, 2] != ""
}

PinyinHistoryHasKey(spilt_word)
{
    global history_field_array
    global tooltip_debug
    tooltip_debug[5] .= "`n[" spilt_word ": " history_field_array.HasKey(spilt_word) "]"
    return history_field_array.HasKey(spilt_word)
}

PinyinHistoryUpdateKey(DB, spilt_word, auto_comple:=false, limit_num:=100)
{
    global history_field_array
    if( !PinyinHistoryHasKey(spilt_word) || history_field_array[spilt_word].Length()==2 && history_field_array[spilt_word,2,2]=="" )
    {
        history_field_array[spilt_word] := PinyinSqlGetResult(DB, spilt_word, auto_comple, limit_num)
    }
}

PinyinHistoryGetWords(spilt_word)
{
    global history_field_array
    return history_field_array[spilt_word]
}

PinyinHistoryGetResultLength(spilt_word)
{
    global history_field_array
    return history_field_array[spilt_word].Length()
}

PinyinResultPushHistory(ByRef search_result, spilt_word, max_num := 100)
{
    global history_field_array
    loop % Min(history_field_array[spilt_word].Length(), max_num)
    {
        search_result.Push(CopyObj(history_field_array[spilt_word, A_Index]))
    }
}

PinyinResultInsertAtHistory(ByRef search_result, spilt_word, insert_at := 1, max_num := 100)
{
    local
    global history_field_array
    list_len := history_field_array[spilt_word].Length()
    loop % Min(list_len, max_num)
    {
        search_result.InsertAt(insert_at, CopyObj(history_field_array[spilt_word, list_len+1-A_Index]))
    }
}
