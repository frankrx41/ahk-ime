;*******************************************************************************
; Simple Spell
;
PinyinTranslatorInsertAutpComplete(ByRef translate_result, splitter_result)
{
    local

    profile_text := ImeProfilerBegin(23)
    splitted_string := SplitterResultConvertToString(splitter_result, 1)
    splitted_string .= "*"
    take_up_length := splitter_result.Length()

    TranslatorHistoryUpdateKey(splitted_string, take_up_length)
    TranslatorHistoryInsertResultAt(translate_result, splitted_string, 1)
    profile_text := "[""" SplitterResultConvertToString(splitter_result, 1) """] -> [""" splitted_string """," take_up_length "]"

    ImeProfilerEnd(23, profile_text)
    return
}
