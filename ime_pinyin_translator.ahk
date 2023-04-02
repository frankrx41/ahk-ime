;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef search_result, splitter_result)
{
    local
    loop, 8
    {
        length_count := 9-A_Index
        splitted_string := SplitterResultConvertToString(splitter_result, 1, length_count)

        TranslatorHistoryUpdateKey(splitted_string, length_count)
        if( TranslatorHistoryHasResult(splitted_string) )
        {
            TranslatorHistoryPushResult(search_result, splitted_string)
        }
    }
}

;*******************************************************************************
; 拼音取词
PinyinTranslateFindResult(splitter_result)
{
    local
    ImeProfilerBegin(20)

    search_result           := []

    ; 插入拼音所能组成的候选词
    PinyinTranslatorInsertResult(search_result, splitter_result)

    ; 超级简拼 显示 4 字及以上简拼候选
    PinyinTranslatorInsertSimpleSpell(search_result, splitter_result)

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

    ImeProfilerEnd(20, "`n  - [" SplitterResultGetDisplayText(splitter_result) "] -> ("  search_result.Length() ")" )
    return search_result
}
