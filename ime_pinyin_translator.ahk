;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef translate_result, splitter_result)
{
    local
    profile_text := ImeProfilerBegin(21)

    hope_word_length := SplitterResultGetHopeLength(splitter_result[1])
    next_length := SplitterResultGetHopeLength(splitter_result[hope_word_length+1])
    next_length := next_length ? next_length : 0
    max_len := hope_word_length + next_length
    profile_text .= "`n  - (" next_length "," max_len "," hope_word_length "): "

    loop, % max_len
    {
        length_count := max_len-A_Index+1
        splitted_string := SplitterResultArrayConvertToString(splitter_result, 1, length_count)
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
PinyinTranslateFindResult(splitter_result, auto_complete)
{
    local
    profile_text := ImeProfilerBegin(20)

    translate_result           := []

    ; Insert db result
    PinyinTranslatorInsertResult(translate_result, splitter_result)


    if( auto_complete )
    {
        ; Insert simple spell, need end with "**"
        PinyinTranslatorInsertAutpComplete(translate_result, splitter_result)
    }
    else
    {
        ; Insert auto combine word
        PinyinTranslatorInsertCombineWord(translate_result, splitter_result)
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

    ImeProfilerEnd(20, profile_text . "`n  - [" SplitterResultArrayGetDisplayText(splitter_result) "] -> ("  translate_result.Length() ")" )
    return translate_result
}
