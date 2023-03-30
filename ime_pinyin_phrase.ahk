PinyinResultInsertWords(ByRef DB, ByRef search_result, input_spilt_string)
{
    local
    ; 插入候选词部分
    spilt_word := input_spilt_string

    loop, 8
    {
        While( spilt_word && !PinyinHistoryHasResult(spilt_word) )
        {
            PinyinHistoryUpdateKey(DB, spilt_word)
            if( PinyinHistoryHasResult(spilt_word) ){
                break
            }
            spilt_word := SplitWordRemoveLastWord(spilt_word)
        }
        if( spilt_word )
        {
            PinyinResultPushHistory(search_result, spilt_word)
        }

        spilt_word := SplitWordRemoveLastWord(spilt_word)
        if( spilt_word == "" )
        {
            break
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
    ImeProfilerBegin(20)

    search_result           := []

    ; 插入拼音所能组成的候选词
    PinyinResultInsertWords(DB, search_result, ime_input_split)

    ; 超级简拼 显示 4 字及以上简拼候选
    PinyinResultInsertSimpleSpell(DB, search_result, ime_input_split)

    if( ImeModeGetLanguage() == "tw" )
    {
        PinyinResultCovertTraditional(search_result)
    }

    PinyinResultRemoveZeroIndex(search_result)
    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd(20)
    return search_result
}
