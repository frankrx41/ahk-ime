PinyinResultInsertWords(ByRef DB, input_spilt_string, ByRef search_result)
{
    local
    ; 插入候选词部分
    spilt_word := SplitWordRemoveLastWord(input_spilt_string)
    While( SplitWordGetWordCount(spilt_word)>1 && !PinyinHistoryHasResult(spilt_word) )
    {
        PinyinHistoryUpdateKey(DB, spilt_word)
        if( PinyinHistoryHasResult(spilt_word) ){
            break
        }
        spilt_word := SplitWordRemoveLastWord(spilt_word)
    }
    if( SplitWordGetWordCount(spilt_word)>1 )
    {
        PinyinHistoryUpdateKey(DB, spilt_word)
        PinyinResultPushHistory(search_result, spilt_word)
    }
    return
}

PinyinResultInsertSingleWord(ByRef DB, ByRef search_result, input_split_string)
{
    local
    first_word := SplitWordTrimMaxCount(input_split_string, 1)
    PinyinHistoryUpdateKey(DB, first_word)
    PinyinResultPushHistory(search_result, first_word)
    return
}

PinyinResultHideZeroWeight(ByRef search_result)
{
    local
    if( search_result[1, 3]>0 )
    {
        loop % len := search_result.Length()
        {
            weight := search_result[len+1-A_Index, 3]
            if( weight<=0 ) {
                search_result.RemoveAt(len+1-A_Index)
            }
        }
    }
    return
}

PinyinResultRemoveZeroIndex(ByRef search_result)
{
    ; [0] is store "pinyin"
    if( search_result.HasKey(0) ){
        search_result.Delete(0)
    }
    return
}

;*******************************************************************************
; 拼音取词
PinyinGetSentences(ime_orgin_input, ime_input_split:="", DB:="")
{
    local
    ; static save_field_array := []
    search_result           := []
    save_field_array        := []

    if( StrLen(ime_orgin_input) == 1 && !InStr("aloe", ime_orgin_input) )
    {
        search_result[1] := [ime_orgin_input, ime_orgin_input, "N/A"]
        return search_result
    }
    else
    {
        if( ime_input_split == "" ) {
            ime_input_split := PinyinSplit(ime_orgin_input, "")
        }

        ; Do sql get result
        PinyinProcess(DB, save_field_array, ime_input_split)

        ; 字数大于1时 组词
        if( SplitWordGetWordCount(ime_input_split)>1 )
        {
            PinyinResultInsertCombine(DB, save_field_array, search_result)
        }

        ; 插入前面个拼音所能组成的候选词
        PinyinResultInsertWords(DB, ime_input_split, search_result)

        ; 插入字部分
        PinyinResultInsertSingleWord(DB, search_result, ime_input_split)

        ; 更新辅助码
        PinyinResultUpdateRadical(search_result)

        ; 超级简拼 显示 4 字及以上简拼候选
        PinyinResultInsertSimpleSpell(DB, search_result, ime_orgin_input)

        ; 隐藏词频低于 0 的词条，仅在无其他候选项的时候出现
        PinyinResultHideZeroWeight(search_result)


        PinyinResultRemoveZeroIndex(search_result)
    }
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    return search_result
}
