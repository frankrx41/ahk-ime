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
        loop % splitter_result_list.Length()
        {
            radical_list.Push(SplitterResultGetRadical(splitter_result_list[A_Index]))
            test_splitter_list := SplitterResultListGetUntilSkip(splitter_result_list, A_Index)
            debug_text .= """" SplitterResultListGetDisplayText(test_splitter_list) ""","
            if( !SplitterResultNeedTranslate(splitter_result_list[A_Index]) || SplitterResultIsAutoSymbol(splitter_result_list[A_Index]) )
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
                if( ImeModeIsChinese() ){
                    translate_result_list := PinyinTranslateFindResult(test_splitter_list, auto_complete)
                } else
                if( ImeModeIsJapanese() ) {
                    translate_result_list := GojuonTranslateFindResult(test_splitter_list, auto_complete)
                }
                if( translate_result_list.Length() == 0 ){
                    first_word := SplitterResultListConvertToString(splitter_result_list, A_Index, 1)
                    translate_result_list := [TranslatorResultMakeNoSelect(first_word, first_word)]
                }
            }
            ; Insert result
            ime_candidata_result_origin.Push(translate_result_list)
        }
        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(30, debug_text)
        ime_candidata_result_origin := CandidateResultListFilterResults(ime_candidata_result_origin, radical_list)
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
    return CandidateGetTranslatorListLength(ImeCandidateGet(), split_index)
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
