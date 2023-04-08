;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef search_result, splitter_result)
{
    local
    max_len := Min(8, splitter_result.Length())
    loop, % max_len
    {
        length_count := max_len-A_Index+1
        hope_word_length := SplitterResultGetWordLength(splitter_result, 1)
        splitted_string := SplitterResultConvertToString(splitter_result, 1, length_count)

        TranslatorHistoryUpdateKey(splitted_string, length_count)
        if( TranslatorHistoryHasResult(splitted_string) )
        {
            if( hope_word_length == length_count ) {
                TranslatorHistoryInsertResult(search_result, splitted_string, 1)
            }
            else {
                TranslatorHistoryPushResult(search_result, splitted_string)
            }
        }
    }
}

;*******************************************************************************
; 拼音取词
PinyinTranslateFindResult(splitter_result)
{
    local
    profile_text := ImeProfilerBegin(20)

    search_result           := []

    ; 插入拼音所能组成的候选词
    PinyinTranslatorInsertResult(search_result, splitter_result)

    ; 超级简拼 显示 4 字及以上简拼候选
    PinyinTranslatorInsertSimpleSpell(search_result, splitter_result)

    if( ImeModeGetLanguage() == "tw" )
    {
        PinyinResultCovertTraditional(search_result)
    }

    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd(20, profile_text . "`n  - [" SplitterResultGetDisplayText(splitter_result) "] -> ("  search_result.Length() ")" )
    return search_result
}
