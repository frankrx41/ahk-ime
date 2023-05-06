;*******************************************************************************
; Simple Spell
;
PinyinTranslatorInsertAutpComplete(ByRef translate_result_list, splitter_result)
{
    local

    profile_text := ImeProfilerBegin(23)
    splitted_string := SplitterResultListConvertToString(splitter_result, 1)
    splitted_string .= "*"
    take_up_length := splitter_result.Length()

    TranslatorHistoryUpdateKey(splitted_string, take_up_length)
    TranslatorHistoryInsertResultAt(translate_result_list, splitted_string, 1)
    profile_text := "[""" SplitterResultListConvertToString(splitter_result, 1) """] -> [""" splitted_string """," take_up_length "]"

    ImeProfilerEnd(23, profile_text)
    return
}
