PinyinHistoryClear()
{
    global history_field_array := []
}

PinyinHistoryHasResult(pinyin)
{
    global history_field_array
    return history_field_array[pinyin, 1, 2] != ""
}

PinyinHistoryHasKey(pinyin)
{
    global history_field_array
    global tooltip_debug
    tooltip_debug[5] .= "`n[" pinyin ": " history_field_array.HasKey(pinyin) "]"
    return history_field_array.HasKey(pinyin)
}

PinyinHistoryUpdateKey(DB, pinyin, limit_num:=100)
{
    global history_field_array
    if( !PinyinHistoryHasKey(pinyin) || history_field_array[pinyin].Length()==2 && history_field_array[pinyin,2,2]=="" )
    {
        history_field_array[pinyin] := PinyinSqlGetResult(DB, pinyin, limit_num)
    }
}

PinyinHistoryGetWords(pinyin)
{
    global history_field_array
    return history_field_array[pinyin]
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
