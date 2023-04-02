;*******************************************************************************
;
PinyinTranslateInsertResult(ByRef search_result, splitted_input)
{
    local
    splitted_string := splitted_input

    loop, 8
    {
        While( splitted_string && !PinyinHistoryHasResult(splitted_string) )
        {
            PinyinHistoryUpdateKey(splitted_string)
            if( PinyinHistoryHasResult(splitted_string) ){
                break
            }
            splitted_string := SplittedInputRemoveLastWord(splitted_string)
        }
        if( splitted_string )
        {
            PinyinResultPushHistory(search_result, splitted_string)
        }

        splitted_string := SplittedInputRemoveLastWord(splitted_string)
        if( splitted_string == "" )
        {
            break
        }
    }
}

;*******************************************************************************
; 拼音取词
PinyinTranslateFindResult(splitted_input)
{
    local
    ImeProfilerBegin(20)

    search_result           := []

    ; 插入拼音所能组成的候选词
    PinyinTranslateInsertResult(search_result, splitted_input)

    ; 超级简拼 显示 4 字及以上简拼候选
    PinyinTranslateInsertSimpleSpell(search_result, splitted_input)

    if( ImeModeGetLanguage() == "tw" )
    {
        PinyinResultCovertTraditional(search_result)
    }

    ; TODO: remove this
    if( search_result.HasKey(0) ){
        search_result.Delete(0)
    }
    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd(20)
    return search_result
}
