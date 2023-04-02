ImeTranslatorInitialize()
{
    global ime_translator_result_list_origin
    global ime_translator_result_list_filtered
    ImeTranslatorClear()
}

ImeTranslatorClear()
{
    global ime_translator_result_list_origin    := []
    global ime_translator_result_list_filtered  := []
}

ImeTranslatorUpdateResult(splitter_result)
{
    local
    global ime_translator_result_list_origin
    global ime_translator_result_list_filtered

    if( splitter_result.Length() )
    {
        ImeProfilerBegin(30)
        ime_translator_result_list_origin := []
        radical_list := []
        debug_text := "["
        loop % splitter_result.Length()
        {
            radical_list.Push(SplitterResultGetRadical(splitter_result, A_Index))
            find_split_string := SplitterResultConvertToStringUntilSkip(splitter_result, A_Index)
            debug_text .= """" find_split_string ""","
            if( SplitterResultIsSkip(splitter_result, A_Index) )
            {
                ; Add legacy text
                translate_result := [[find_split_string, find_split_string, 0, "", 1]]
                if( RegexMatch(find_split_string, "^\s+$") ) {
                    translate_result[1,2] := ""
                }
            }
            else
            {
                Assert(find_split_string)
                ; Get translate result
                translate_result := PinyinTranslateFindResult(find_split_string)
                if( translate_result.Length() == 0 ){
                    first_word := SplitterResultConvertToString(splitter_result, A_Index)
                    translate_result := [[first_word, first_word, 0, "", 1]]
                }
            }
            ; Insert result
            ime_translator_result_list_origin.Push(translate_result)
        }
        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(30, debug_text)
        ime_translator_result_list_filtered := TranslatorResultListFilterResults(ime_translator_result_list_origin, radical_list)
    } else {
        ImeTranslatorClear()
    }
}

ImeTranslatorResultFindIndex(split_index, start_words, max_length)
{
    global ime_translator_result_list_filtered
    return TranslatorResultListFindIndex(ime_translator_result_list_filtered, split_index, start_words, max_length)
}

;*******************************************************************************
;
ImeTranslatorResultListGetLength()
{
    global ime_translator_result_list_filtered
    return ime_translator_result_list_filtered.Length()
}

;*******************************************************************************
;
ImeTranslatorResultListGetListLength(split_index)
{
    global ime_translator_result_list_filtered
    return ime_translator_result_list_filtered[split_index].Length()
}

ImeTranslatorResultListGetPinyin(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetPinyin(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWord(split_index, word_index)
{
    global ime_translator_result_list_filtered
    ImeProfilerBegin(1)
    ImeProfilerEnd(1, split_index "," word_index)
    return TranslatorResultGetWord(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWeight(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetWeight(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetComment(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetComment(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWordLength(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetWordLength(ime_translator_result_list_filtered[split_index], word_index)
}

;*******************************************************************************
;
ImeTranslatorResultGetFormattedComment(split_index, word_index)
{
    comment := ImeTranslatorResultListGetComment(split_index, word_index)
    if( comment ){
        if( comment == "name" ){
            return "名"
        } else {
            return comment
        }
    } else {
        return ""
    }
}
