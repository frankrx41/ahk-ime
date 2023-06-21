ImeCandidateInitialize()
{
    global ime_candidata
    ImeCandidateClear()
}

ImeCandidateClear()
{
    global ime_candidata := []
}

ImeCandidateUpdateResult(splitter_result_list)
{
    local
    global ime_candidata

    if( splitter_result_list.Length() )
    {
        ImeProfilerBegin()
        ime_candidata := []
        translate_last_result_list := []
        CandidateSetSplittedList(ime_candidata, splitter_result_list)
        debug_text := "["
        loop % splitter_result_list.Length()
        {
            splitter_index := A_Index
            test_splitter_list := SplitterResultListGetUntilSkip(splitter_result_list, splitter_index)
            debug_text .= """" SplitterResultListGetDebugText(test_splitter_list) ""","
            if( !SplitterResultNeedTranslate(splitter_result_list[splitter_index]) || SplitterResultIsAutoSymbol(splitter_result_list[splitter_index]) )
            {
                ; Add legacy text
                test_string := SplitterResultGetPinyin(test_splitter_list[1])
                if( RegexMatch(test_string, "^\s*$") ) {
                    translate_result_list := [TranslatorResultMake(test_string, "", 0, "", 1)]
                } else {
                    translate_result_list := [TranslatorResultMake(test_string, test_string, 0, "", 1)]
                }
            }
            else
            {
                Assert(test_splitter_list.Length() >= 1, "", false)
                ; Get translate result
                translate_result_list := ImeTranslateFindResult(test_splitter_list)
                if( translate_result_list.Length() == 0 ){
                    first_word := SplitterResultListConvertToString(splitter_result_list, splitter_index, 1)
                    translate_result_list := [TranslatorResultMake(first_word, first_word, 0, "", 1)]
                }
            }
            ; Insert result
            ime_candidata.Push(translate_result_list)

            loop, % translate_result_list.Length()
            {
                if( TranslatorResultGetWordLength(translate_result_list[A_Index]) + splitter_index-1 == splitter_result_list.Length() ){
                    translate_last_result_list.Push(translate_result_list[A_Index])
                } else {
                    break
                }
            }
        }
        ; Add last length word
        ime_candidata.Push(translate_last_result_list)

        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(debug_text)
    } else {
        ImeCandidateClear()
    }

    return ime_candidata
}

ImeCandidateSetSingleMode(single_mode)
{
    local
    global ime_candidata
    split_index := ImeInputterGetCaretSplitIndex()
    splitted_list := CandidateGetSplittedList(ime_candidata)
    if( single_mode ){
        test_splitter_list := []
        test_splitter_list.Push(splitted_list[split_index])
    } else {
        test_splitter_list := SplitterResultListGetUntilSkip(splitted_list, split_index)
    }
    ime_candidata[split_index] := ImeTranslateFindResult(test_splitter_list)
}

ImeCandidateGet()
{
    global ime_candidata
    return ime_candidata
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

ImeCandidateGetTopLevel(split_index, word_index)
{
    return CandidateGetTopLevel(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateIsDisable(split_index, word_index)
{
    return CandidateIsDisable(ImeCandidateGet(), split_index, word_index)
}

ImeCandidateGetMatchLevel(split_index, word_index)
{
    return CandidateGetMatchLevel(ImeCandidateGet(), split_index, word_index)
}

;*******************************************************************************
;
ImeCandidateGetFormattedComment(split_index, word_index)
{
    return CandidateGetFormattedComment(ImeCandidateGet(), split_index, word_index)
}
