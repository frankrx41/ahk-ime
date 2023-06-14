#Include, src\pinyin\lib_pinyin_translator_auto_complete.ahk
#Include, src\pinyin\lib_pinyin_translator_combine_word.ahk
#Include, src\pinyin\lib_pinyin_translator_traditional.ahk
#Include, src\pinyin\lib_pinyin_translator_resplitter.ahk

;*******************************************************************************
;
PinyinTranslatorInsertResult(ByRef translate_result_list, splitter_result_list)
{
    local
    ImeProfilerBegin()

    hope_word_length := SplitterResultGetHopeLength(splitter_result_list[1])
    next_length := SplitterResultGetHopeLength(splitter_result_list[hope_word_length+1])
    next_length := next_length ? next_length : 0
    max_len := hope_word_length + next_length
    profile_text := "(" next_length "," max_len "," hope_word_length "): "

    max_len := Min(max_len, 8)
    loop, % max_len
    {
        length_count := max_len-A_Index+1
        ; If only one word and has no radical, we skip it for optimization
        splitted_string := SplitterResultListConvertToString(splitter_result_list, 1, length_count)
        if( length_count == 1 && translate_result_list.Length() > 0 && !SplitterResultGetRadical(splitter_result_list[1]) && !ImeTranslatorHistoryHasKey(splitted_string))
        {
            Assert(false)
            break
        }
        profile_text .= "[" splitted_string "] "
        limit_num := length_count == 1 ? 800 : 100
        ImeTranslatorHistoryUpdateKey(splitted_string, limit_num)
        if( length_count == hope_word_length ) {
            first_weight := TranslatorResultGetWeight(translate_result_list[1])
            last_index := translate_result_list.Length() + 1
        }
        ImeTranslatorHistoryPushResult(translate_result_list, splitted_string, length_count, limit_num)
    }
    ImeProfilerEnd(profile_text)
}

;*******************************************************************************
; Get translate result *ONLY* for splitter_result[1]
PinyinTranslateFindResult(splitter_result_list, auto_complete)
{
    local
    ImeProfilerBegin()

    translate_result_list := []

    ; Insert db result
    PinyinTranslatorInsertResult(translate_result_list, splitter_result_list)


    if( auto_complete )
    {
        ; Insert simple spell, need end with "**"
        PinyinTranslatorInsertAutoComplete(translate_result_list, splitter_result_list)
    }
    else
    {
        ; Insert auto combine word
        PinyinTranslatorInsertCombineWord(translate_result_list, splitter_result_list)
    }

    ; gua'mo -> gu'a'mo
    if( splitter_result_list.Length() > 1 )
    {
        PinyinTranslatorInsertReSplitter(translate_result_list, splitter_result_list)
    }

    if( ImeLanguageIsTraChinese() )
    {
        PinyinTranslatorCovertTraditional(translate_result_list)
    }

    ; Sort
    ; translate_result_list := TranslatorResultListSortByWeight(translate_result_list)

    ; [
    ;     ; 1   , 2   , 3      , 4 , 5  
    ;     ["wo3", "我", "30233", "", "1"]
    ;     ["wo1", "窝", "30219", "", "1"]
    ;     ...
    ; ]

    ImeProfilerEnd("[" SplitterResultListGetDebugText(splitter_result_list) "] -> ("  translate_result_list.Length() ")" )
    return translate_result_list
}
