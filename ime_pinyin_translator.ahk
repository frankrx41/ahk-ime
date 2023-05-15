;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef translate_result_list, splitter_result)
{
    local
    profile_text := ImeProfilerBegin(21)

    hope_word_length := SplitterResultGetHopeLength(splitter_result[1])
    next_length := SplitterResultGetHopeLength(splitter_result[hope_word_length+1])
    next_length := next_length ? next_length : 0
    max_len := hope_word_length + next_length
    profile_text .= "`n  - (" next_length "," max_len "," hope_word_length "): "

    max_len := Min(max_len, 8)
    loop, % max_len
    {
        length_count := max_len-A_Index+1
        splitted_string := SplitterResultListConvertToString(splitter_result, 1, length_count)
        profile_text .= "[" splitted_string "] "
        TranslatorHistoryUpdateKey(splitted_string, length_count)
        if( length_count == hope_word_length ) {
            first_weight := TranslatorResultGetWeight(translate_result_list[1])
            last_index := translate_result_list.Length() + 1
        }
        TranslatorHistoryPushResult(translate_result_list, splitted_string, 200)
        if( length_count == hope_word_length && TranslatorResultGetWeight(translate_result_list[last_index]) > first_weight + 2000) {
            TranslatorHistoryInsertResultAt(translate_result_list, splitted_string, 1, 1)
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

    translate_result_list := []

    ; Insert db result
    PinyinTranslatorInsertResult(translate_result_list, splitter_result)


    if( auto_complete )
    {
        ; Insert simple spell, need end with "**"
        PinyinTranslatorInsertAutoComplete(translate_result_list, splitter_result)
    }
    else
    {
        ; Insert auto combine word
        PinyinTranslatorInsertCombineWord(translate_result_list, splitter_result)
    }

    if( ImeModeIsTraChinese() )
    {
        PinyinResultCovertTraditional(translate_result_list)
    }

    ; Sort
    ; translate_result_list := TranslatorResultListSortByWeight(translate_result_list)

    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd(20, profile_text . "`n  - [" SplitterResultListGetDisplayText(splitter_result) "] -> ("  translate_result_list.Length() ")" )
    return translate_result_list
}
