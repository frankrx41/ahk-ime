PinyinResultInsertWords(ByRef DB, ByRef search_result, input_spilt_string)
{
    local
    ; 插入候选词部分
    spilt_word := input_spilt_string

    loop, 4
    {
        While( !PinyinHistoryHasResult(spilt_word) )
        {
            PinyinHistoryUpdateKey(DB, spilt_word)
            if( PinyinHistoryHasResult(spilt_word) ){
                break
            }
            spilt_word := SplitWordRemoveLastWord(spilt_word)
        }
        PinyinResultPushHistory(search_result, spilt_word)
        spilt_word := SplitWordRemoveLastWord(spilt_word)
        if( spilt_word == "" ){
            break
        }
    }
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
PinyinGetTranslateResult(ime_input_split, DB:="")
{
    local
    ; static save_field_array := []
    search_result           := []

    ; Do sql get result
    PinyinProcess(DB, ime_input_split)

    ; 插入拼音所能组成的候选词
    PinyinResultInsertWords(DB, search_result, ime_input_split)

    ; 超级简拼 显示 4 字及以上简拼候选
    PinyinResultInsertSimpleSpell(DB, search_result, ime_input_split)

    ; 隐藏词频低于 0 的词条，仅在无其他候选项的时候出现
    PinyinResultHideZeroWeight(search_result)


    PinyinResultRemoveZeroIndex(search_result)
    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]
    return search_result
}
