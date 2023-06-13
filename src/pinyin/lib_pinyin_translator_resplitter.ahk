PinyinTranslatorInsertReSplitter(ByRef translate_result_list, splitter_result_list)
{
    Assert( splitter_result_list.Length() > 1 )
    splitted_string := SplitterResultListConvertToString(splitter_result_list, 1)
    ; For make sure "ma0l%0 can not match "ma3liao4"
    splitted_string := StrReplace(splitted_string, "%")

    profile_text := splitted_string
    ImeProfilerBegin(27)
    if( IsPinyinSoundLike(splitted_string, "gua1mo4") ){
        splitted_string := "gu3a1mo4"
        ImeTranslatorHistoryUpdateKey(splitted_string)
        ImeTranslatorHistoryInsertResultAt(translate_result_list, splitted_string, 2)
    }
    if( IsPinyinSoundLike(splitted_string, "ma3liao4") ){
        splitted_string := "ma3li3ao4"
        ImeTranslatorHistoryUpdateKey(splitted_string)
        ImeTranslatorHistoryInsertResultAt(translate_result_list, splitted_string, 2)
    }
    ImeProfilerEnd(27, profile_text)
}
