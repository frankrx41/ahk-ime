PinyinTranslatorInsertCombineWord(ByRef translate_result, splitter_result)
{
    splitter_result := SplitterResultGetUntilLength(splitter_result)
    splitted_string := SplitterResultConvertToString(splitter_result, 1, 0)
    if( TranslatorHistoryHasResult(splitted_string) ){
        return
    }
    ; A-le-X-B
    profile_text := ImeProfilerBegin(22)
    if( splitter_result.Length() >= 4 && RegexMatch(SplitterResultConvertToString(splitter_result, 2, 1), "^(le0|le1)$" ) ){
        splitted_string := ""
        word_length := 0
        splitted_string .= SplitterResultConvertToString(splitter_result, 1, 1)
        splitted_string .= SplitterResultConvertToString(splitter_result, 4, word_length)
        TranslatorHistoryUpdateKey(splitted_string, 2)

        first_word := TranslatorHistoryGetResultWord(splitted_string)
        if( first_word ){
            splitted_string := SplitterResultConvertToString(splitter_result, 3, 1)
            TranslatorHistoryUpdateKey(splitted_string, 1)

            full_word := SubStr(first_word, 1, 1) . "了" . TranslatorHistoryGetResultWord(splitted_string) . SubStr(first_word, 2)

            total_word_length := word_length+3
            Assert(total_word_length == splitter_result.Length())
            pinyin := SplitterResultConvertToString(splitter_result, 1, total_word_length)
            single_result := TranslatorSingleResultMake(pinyin, full_word, 0, "auto", total_word_length)
            translate_result.InsertAt(1, single_result)
        }
    }
    ; A-XXX-B
    if( splitter_result.Length() > 2 ){
        splitted_string := ""
        splitted_string .= SplitterResultConvertToString(splitter_result, 1, 1)
        splitted_string .= SplitterResultConvertToString(splitter_result, 0, 1)
        TranslatorHistoryUpdateKey(splitted_string, 2)

        first_word := TranslatorHistoryGetResultWord(splitted_string)
        if( first_word ){
            word_length := splitter_result.Length()-2
            splitted_string := SplitterResultConvertToString(splitter_result, 2, word_length)
            TranslatorHistoryUpdateKey(splitted_string, 1, word_length)

            middle_word := TranslatorHistoryGetResultWord(splitted_string)
            if( middle_word )
            {
                full_word := SubStr(first_word, 1, 1) . middle_word . SubStr(first_word, 2, 1)
                total_word_length := splitter_result.Length()
                pinyin := SplitterResultConvertToString(splitter_result, 1, total_word_length)
                single_result := TranslatorSingleResultMake(pinyin, full_word, 0, "auto", total_word_length)
                translate_result.InsertAt(1, single_result)
            }
        }
    }
    ImeProfilerEnd(22, profile_text)
}
