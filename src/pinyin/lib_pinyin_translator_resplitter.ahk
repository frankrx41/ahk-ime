PinyinTranslatorInsertReSplitter(ByRef translate_result_list, splitter_result_list)
{
    splitted_string := SplitterResultListConvertToString(splitter_result_list, 1)
    if( splitted_string == "gua0mo0" ){
        splitted_string := "gu0a0mo0"
        ImeTranslatorHistoryUpdateKey(splitted_string)
        ImeTranslatorHistoryInsertResultAt(translate_result_list, splitted_string, 2)
    }
}
