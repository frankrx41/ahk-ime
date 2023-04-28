PinyinTranslatorInsertCombineWord(ByRef translate_result, splitter_result)
{
    ; A-lege-B
    if( SplitterResultGetPinyin(splitter_result, 2) == "le" ){
        splitted_string := ""
        word_length := 0
        splitted_string .= SplitterResultConvertToString(splitter_result, 1, 1)
        splitted_string .= SplitterResultConvertToString(splitter_result, 4, word_length)
        TranslatorHistoryUpdateKey(splitted_string, 2)

        splitted_string_3rd := SplitterResultConvertToString(splitter_result, 3, 1)
        TranslatorHistoryUpdateKey(splitted_string_3rd, 1)

        total_word_length := 3 + word_length
        pinyin := SplitterResultConvertToString(splitter_result, 1, total_word_length)

        word := TranslatorHistoryGetResultWord(splitted_string)
        if( word ){
            word := SubStr(word, 1, 1) . "了" . TranslatorHistoryGetResultWord(splitted_string_3rd) . SubStr(word, 2)
            single_result := TranslatorSingleResultMake(pinyin, word, 0, "auto", total_word_length)
            translate_result.InsertAt(1, single_result)
        }
    }
}
