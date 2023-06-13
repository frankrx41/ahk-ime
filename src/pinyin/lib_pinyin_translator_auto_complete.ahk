;*******************************************************************************
; Simple Spell
;
PinyinTranslatorInsertAutoComplete(ByRef translate_result_list, splitter_result_list)
{
    local

    ImeProfilerBegin()
    splitted_string := SplitterResultListConvertToString(splitter_result_list, 1)
    splitted_string .= "*"
    take_up_length := splitter_result_list.Length()

    ImeTranslatorHistoryUpdateKey(splitted_string)
    ImeTranslatorHistoryInsertResultAt(translate_result_list, splitted_string, splitter_result_list.Length(), 1)
    profile_text := "[""" SplitterResultListConvertToString(splitter_result_list, 1) """] -> [""" splitted_string """," take_up_length "]"

    ImeProfilerEnd(profile_text)
    return
}
