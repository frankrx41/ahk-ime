ImeCandidateInitialize()
{
    global ime_candidata_result_filter
    global ime_candidata_result_origin
    ImeCandidateClear()
}

ImeCandidateClear()
{
    global ime_candidata_result_filter  := []
    global ime_candidata_result_origin  := []
}

ImeCandidateUpdateResult(splitter_result_list)
{
    local
    global ime_candidata_result_filter
    global ime_candidata_result_origin

    auto_complete := false

    if( splitter_result_list.Length() )
    {
        debug_text := ImeProfilerBegin(30)
        ime_candidata_result_origin := []
        CandidateSetSplittedList(ime_candidata_result_origin, splitter_result_list)
        radical_list := []
        debug_text := "["
        translate_last_result_list := []
        loop % splitter_result_list.Length()
        {
            splitter_index := A_Index
            radical_list.Push(SplitterResultGetRadical(splitter_result_list[splitter_index]))
            test_splitter_list := SplitterResultListGetUntilSkip(splitter_result_list, splitter_index)
            debug_text .= """" SplitterResultListGetDisplayText(test_splitter_list) ""","
            if( !SplitterResultNeedTranslate(splitter_result_list[splitter_index]) || SplitterResultIsAutoSymbol(splitter_result_list[splitter_index]) )
            {
                ; Add legacy text
                test_string := SplitterResultGetPinyin(test_splitter_list[1])
                if( RegexMatch(test_string, "^\s*$") ) {
                    translate_result_list := [TranslatorResultMakeNoSelect(test_string, "")]
                } else {
                    translate_result_list := [TranslatorResultMakeNoSelect(test_string, test_string)]
                }
            }
            else
            {
                Assert(test_splitter_list.Length() >= 1)
                ; Get translate result
                translate_result_list := ImeTranslateFindResult(test_splitter_list, auto_complete)
                if( translate_result_list.Length() == 0 ){
                    first_word := SplitterResultListConvertToString(splitter_result_list, splitter_index, 1)
                    translate_result_list := [TranslatorResultMakeNoSelect(first_word, first_word)]
                }
            }
            ; Insert result
            ime_candidata_result_origin.Push(translate_result_list)
        }

        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(30, debug_text)
        ime_candidata_result_origin := CandidateResultListFilterResults(ime_candidata_result_origin, radical_list)

        loop, % ime_candidata_result_origin.Length()
        {
            splitter_index := A_Index
            translate_result_list := ime_candidata_result_origin[A_Index]
            loop, % translate_result_list.Length()
            {
                if( TranslatorResultGetWordLength(translate_result_list[A_Index]) + splitter_index-1 == splitter_result_list.Length() ){
                    translate_last_result_list.Push(translate_result_list[A_Index])
                } else {
                    break
                }
            }
        }
        ime_candidata_result_origin.Push(translate_last_result_list)

        ime_candidata_result_filter := CopyObj(ime_candidata_result_origin)
    } else {
        ImeCandidateClear()
    }

    return ime_candidata_result_filter
}

ImeCandidateSetSingleMode(single_mode)
{
    global ime_candidata_result_filter
    global ime_candidata_result_origin

    if( single_mode ){
        ime_candidata_result_filter := CandidateResultListFilterResultsSingleMode(ime_candidata_result_origin)
    } else {
        ime_candidata_result_filter := ime_candidata_result_origin
    }
}

ImeCandidateGet()
{
    global ime_candidata_result_filter
    return ime_candidata_result_filter
}

;*******************************************************************************
;
ImeCandidateGetTranslatorListLength(split_index)
{
    return ImeCandidateGet()[split_index].Length()
}

ImeCandidateGetLegacyPinyin(split_index, word_index)
{
    return CandidateGetLegacyPinyin(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateGetWord(split_index, word_index)
{
    return CandidateGetWord(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateGetWeight(split_index, word_index)
{
    return CandidateGetWeight(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateGetComment(split_index, word_index)
{
    return CandidateGetComment(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateGetWordLength(split_index, word_index)
{
    return CandidateGetWordLength(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateIsTraditional(split_index, word_index)
{
    return CandidateIsTraditional(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateIsTop(split_index, word_index)
{
    return CandidateIsTop(ImeCandidateGet(), split_index, word_index)
}

;*******************************************************************************
;
ImeCandidateGetFormattedComment(split_index, word_index)
{
    return CandidateGetFormattedComment(ImeCandidateGet(), split_index, word_index)
}
