;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef translate_result, splitter_result)
{
    local
    profile_text := ImeProfilerBegin(21)

    hope_word_length := SplitterResultGetWordLength(splitter_result, 1)
    next_length := SplitterResultGetWordLength(splitter_result, hope_word_length+1)
    next_length := next_length ? next_length : 0
    max_len := hope_word_length + next_length
    profile_text .= "`n  - (" next_length "," max_len "," hope_word_length "): "

    loop, % max_len
    {
        length_count := max_len-A_Index+1
        splitted_string := SplitterResultConvertToString(splitter_result, 1, length_count)
        profile_text .= "[" splitted_string "] "
        TranslatorHistoryUpdateKey(splitted_string, length_count)
        TranslatorHistoryPushResult(translate_result, splitted_string, 200)
        if( length_count == hope_word_length ) {
            TranslatorHistoryInsertResultAt(translate_result, splitted_string, 1, 3)
        }
    }
    ImeProfilerEnd(21, profile_text)
}

;*******************************************************************************
; Get translate result *ONLY* for splitter_result[1]
PinyinTranslateFindResult(splitter_result, auto_comple)
{
    local
    profile_text := ImeProfilerBegin(20)

    translate_result           := []

    ; 插入拼音所能组成的候选词
    PinyinTranslatorInsertResult(translate_result, splitter_result)

    ; 超级简拼 显示 4 字及以上简拼候选
    if( auto_comple )
    {
        PinyinTranslatorInsertSimpleSpell(translate_result, splitter_result)
    }

    if( ImeModeGetLanguage() == "tw" )
    {
        PinyinResultCovertTraditional(translate_result)
    }

    ; Sort
    ; TranslatorResultSortByWeight(translate_result)

    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd(20, profile_text . "`n  - [" SplitterResultGetDisplayText(splitter_result) "] -> ("  translate_result.Length() ")" )
    return translate_result
}
