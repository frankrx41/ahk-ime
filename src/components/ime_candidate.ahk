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

; splitter_result -> splitter_result_list
ImeCandidateUpdateResult(splitter_result)
{
    local
    global ime_candidata_result_filter
    global ime_candidata_result_origin

    auto_complete := false

    if( splitter_result.Length() )
    {
        debug_text := ImeProfilerBegin(30)
        ime_candidata_result_origin := []
        radical_list := []
        debug_text := "["
        loop % splitter_result.Length()
        {
            radical_list.Push(SplitterResultGetRadical(splitter_result[A_Index]))
            test_splitter_result := SplitterResultListGetUntilSkip(splitter_result, A_Index)
            debug_text .= """" SplitterResultListGetDisplayText(test_splitter_result) ""","
            if( !SplitterResultNeedTranslate(splitter_result[A_Index]) || SplitterResultIsAutoSymbol(splitter_result[A_Index]) )
            {
                ; Add legacy text
                test_string := SplitterResultGetPinyin(test_splitter_result[1])
                if( RegexMatch(test_string, "^\s*$") ) {
                    translate_result_list := [TranslatorResultMake(test_string, "", 0, "", 1)]
                } else {
                    translate_result_list := [TranslatorResultMake(test_string, test_string, 0, "", 1)]
                }
            }
            else
            {
                Assert(test_splitter_result.Length() >= 1)
                ; Get translate result
                if( ImeModeIsChinese() ){
                    translate_result_list := PinyinTranslateFindResult(test_splitter_result, auto_complete)
                } else
                if( ImeModeIsJapanese() ) {
                    translate_result_list := GojuonTranslateFindResult(test_splitter_result, auto_complete)
                }
                if( translate_result_list.Length() == 0 ){
                    first_word := SplitterResultListConvertToString(splitter_result, A_Index, 1)
                    translate_result_list := [TranslatorResultMake(first_word, first_word, 0, "", 1)]
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
CandidateFindIndex(candidata, split_index, start_words, max_length)
{
    return CandidateResultListFindIndex(candidata, split_index, start_words, max_length)
}

CandidateGetTranslatorResult(candidata, split_index, word_index)
{
    return candidata[split_index, word_index]
}

;*******************************************************************************
;
CandidateGetListLength(candidata, split_index)
{
    return candidata[split_index].Length()
}

ImeCandidateGetListLength(split_index)
{
    return CandidateGetListLength(ImeCandidateGet(), split_index)
}

CandidateGetLegacyPinyin(candidata, split_index, word_index)
{
    return TranslatorResultGetLegacyPinyin(candidata[split_index, word_index])
}

ImeCandidateGetLegacyPinyin(split_index, word_index)
{
    return CandidateGetLegacyPinyin(ImeCandidateGet(), split_index, word_index)
}

CandidateGetWord(candidata, split_index, word_index)
{
    return TranslatorResultGetWord(candidata[split_index, word_index])
}

ImeCandidateGetWord(split_index, word_index)
{
    return CandidateGetWord(ImeCandidateGet(), split_index, word_index)
}

CandidateGetWeight(candidata, split_index, word_index)
{
    return TranslatorResultGetWeight(candidata[split_index, word_index])
}

ImeCandidateGetWeight(split_index, word_index)
{
    return CandidateGetWeight(ImeCandidateGet(), split_index, word_index)
}

CandidateGetComment(candidata, split_index, word_index)
{
    return TranslatorResultGetComment(candidata[split_index, word_index])
}

ImeCandidateGetComment(split_index, word_index)
{
    return CandidateGetComment(ImeCandidateGet(), split_index, word_index)
}

CandidateGetWordLength(candidata, split_index, word_index)
{
    return TranslatorResultGetWordLength(candidata[split_index, word_index])
}

ImeCandidateGetWordLength(split_index, word_index)
{
    return CandidateGetWordLength(ImeCandidateGet(), split_index, word_index)
}

CandidateIsTraditional(candidata, split_index, word_index)
{
    return TranslatorResultIsTraditional(candidata[split_index, word_index])
}

ImeCandidateIsTraditional(split_index, word_index)
{
    return CandidateIsTraditional(ImeCandidateGet(), split_index, word_index)
}

;*******************************************************************************
;
CandidateGetFormattedComment(candidata, split_index, word_index)
{
    comment := CandidateGetComment(candidata, split_index, word_index)
    return comment
}

ImeCandidateGetFormattedComment(split_index, word_index)
{
    return CandidateGetFormattedComment(ImeCandidateGet(), split_index, word_index)
}
