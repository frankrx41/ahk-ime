ImeCandidateInitialize()
{
    global ime_candidate_result_list_origin
    global ime_candidata_result_list_filtered
    ImeCandidateClear()
}

ImeCandidateClear()
{
    global ime_candidate_result_list_origin     := []
    global ime_candidata_result_list_filtered   := []
}

ImeCandidateUpdateResult(splitter_result, auto_complete)
{
    local
    global ime_candidate_result_list_origin
    global ime_candidata_result_list_filtered

    if( splitter_result.Length() )
    {
        debug_text := ImeProfilerBegin(30)
        ime_candidate_result_list_origin := []
        radical_list := []
        debug_text := "["
        loop % splitter_result.Length()
        {
            radical_list.Push(SplitterResultGetRadical(splitter_result[A_Index]))
            test_splitter_result := SplitterResultListGetUntilSkip(splitter_result, A_Index)
            debug_text .= """" SplitterResultListGetDisplayText(test_splitter_result) ""","
            if( !SplitterResultNeedTranslate(splitter_result[A_Index]) )
            {
                ; Add legacy text
                test_string := SplitterResultGetPinyin(test_splitter_result[1])
                translate_result_list := [[test_string, test_string, 0, "", 1]]
                if( RegexMatch(test_string, "^\s+$") ) {
                    translate_result_list := [TranslatorResultMake(test_string, "", 0, "", 1)]
                } else {
                    translate_result_list := [TranslatorResultMake(test_string, test_string, 0, "", 1)]
                }
            }
            else
            {
                Assert(test_splitter_result.Length() >= 1)
                ; Get translate result
                translate_result_list := PinyinTranslateFindResult(test_splitter_result, auto_complete)
                if( translate_result_list.Length() == 0 ){
                    first_word := SplitterResultListConvertToString(splitter_result, A_Index)
                    translate_result_list := [TranslatorResultMake(first_word, first_word, 0, "", 1)]
                }
            }
            ; Insert result
            ime_candidate_result_list_origin.Push(translate_result_list)
        }
        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(30, debug_text)
        ime_candidata_result_list_filtered := CandidateResultListFilterResults(ime_candidate_result_list_origin, radical_list)
    } else {
        ImeCandidateClear()
    }
}

ImeCandidateFindIndex(split_index, start_words, max_length)
{
    global ime_candidata_result_list_filtered
    return CandidateResultListFindIndex(ime_candidata_result_list_filtered, split_index, start_words, max_length)
}

;*******************************************************************************
;
ImeCandidateGetLength()
{
    global ime_candidata_result_list_filtered
    return ime_candidata_result_list_filtered.Length()
}

;*******************************************************************************
;
ImeCandidateGetListLength(split_index)
{
    global ime_candidata_result_list_filtered
    return ime_candidata_result_list_filtered[split_index].Length()
}

ImeCandidateGetPinyin(split_index, word_index)
{
    global ime_candidata_result_list_filtered
    return TranslatorResultGetPinyin(ime_candidata_result_list_filtered[split_index, word_index])
}

ImeCandidateGetWord(split_index, word_index)
{
    global ime_candidata_result_list_filtered
    return TranslatorResultGetWord(ime_candidata_result_list_filtered[split_index, word_index])
}

ImeCandidateGetWeight(split_index, word_index)
{
    global ime_candidata_result_list_filtered
    return TranslatorResultGetWeight(ime_candidata_result_list_filtered[split_index, word_index])
}

ImeCandidateGetComment(split_index, word_index)
{
    global ime_candidata_result_list_filtered
    return TranslatorResultGetComment(ime_candidata_result_list_filtered[split_index, word_index])
}

ImeCandidateGetWordLength(split_index, word_index)
{
    global ime_candidata_result_list_filtered
    return TranslatorResultGetWordLength(ime_candidata_result_list_filtered[split_index, word_index])
}

;*******************************************************************************
;
ImeCandidateGetFormattedComment(split_index, word_index)
{
    comment := ImeCandidateGetComment(split_index, word_index)
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
