;*******************************************************************************
; Candidate
;   [0]: splitted_list
;   [1~]: translator_result
;
; Because candidata.Length() will ignore [0], so it still return the length of `translator_result`
CandidateGetSplittedList(ByRef candidata)
{
    return candidata["splitted_list"]
}

CandidateSetSplittedList(ByRef candidata, splitted_list)
{
    candidata["splitted_list"] := splitted_list
}

CandidateGetLegacyPinyin(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetLegacyPinyin(candidata[split_index, word_index])
}

CandidateGetWord(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetWord(candidata[split_index, word_index])
}

CandidateGetWeight(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetWeight(candidata[split_index, word_index])
}

CandidateGetComment(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetComment(candidata[split_index, word_index])
}

CandidateGetWordLength(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetWordLength(candidata[split_index, word_index])
}

CandidateIsTraditional(ByRef candidata, split_index, word_index)
{
    return TranslatorResultIsTraditional(candidata[split_index, word_index])
}

CandidateIsTop(ByRef candidata, split_index, word_index)
{
    return TranslatorResultIsTop(candidata[split_index, word_index])
}

;*******************************************************************************
; [1:"我爱你", 2:"我爱", 3:"我"]
; find ["我"]
;   - max_length == 1 return 3
;   - max_length == 2 return 2
; find ["你"]
;   return 0
CandidateFindIndex(ByRef candidate, split_index, find_words, max_length:=0)
{
    local
    find_word_len := StrLen(find_words)
    if( max_length == 0 ) {
        max_length := find_word_len
    }
    debug_text := ImeProfilerBegin(32)
    debug_text .= split_index "," candidate[split_index].Length()
    select_index := 0
    loop, % candidate[split_index].Length()
    {
        select_index := A_Index
        test_word := TranslatorResultGetWord(candidate[split_index, select_index])
        test_word_length := TranslatorResultGetWordLength(candidate[split_index, select_index])
        if( test_word_length <= max_length && find_words == SubStr(test_word, 1, find_word_len) ){
            debug_text .= "`n  - [" select_index "] -> """ find_words """ == """ test_word """"
            break
        }
    }
    ImeProfilerEnd(32, debug_text)
    return select_index
}

CandidateFindMaxLengthSelectIndex(ByRef candidate, split_index, max_length)
{
    local
    select_index := 0
    loop % candidate[split_index].Length()
    {
        select_index := A_Index
        test_len := TranslatorResultGetWordLength(candidate[split_index, select_index])
        if( test_len <= max_length )
        {
            break
        }
    }
    return select_index
}

;*******************************************************************************
;
CandidateResultListFilterResults(ByRef candidate, input_radical_list)
{
    local
    result_list     := CopyObj(candidate)
    radical_list    := CopyObj(input_radical_list)

    debug_text := ""
    ImeProfilerBegin(31)
    loop % result_list.Length()
    {
        split_index := A_Index
        test_result := result_list[split_index]
        debug_text .= "`n  - [" split_index  ", " CandidateGetLegacyPinyin(result_list, split_index, 1) "] (" test_result.Length() ")"
        if( true ){
            ; TranslatorResultListFilterZeroWeight(test_result)
        }
        if( radical_list ){
            TranslatorResultListFilterByRadical(test_result, radical_list)
            radical_list.RemoveAt(1)
        }
        if( true ){
            TranslatorResultListUniquify(test_result)
        }
        debug_text .= " -> (" test_result.Length() ")"
    }

    ; SelectorFixupSelectIndex()
    ImeProfilerEnd(31, "[" result_list.Length() "]: " . debug_text)
    return result_list
}

CandidateResultListFilterResultsSingleMode(ByRef candidate)
{
    result_list := CopyObj(candidate)
    loop % result_list.Length()
    {
        TranslatorResultListFilterSingleWord(result_list[A_Index])
    }
    return result_list
}

;*******************************************************************************
;
CandidateGetFormattedComment(candidata, split_index, word_index)
{
    comment := CandidateGetComment(candidata, split_index, word_index)
    if( CandidateIsTraditional(candidata, split_index, word_index) ) {
        comment := "*" . comment
    }
    if( CandidateIsTop(candidata, split_index, word_index) ) {
        comment := "^" . comment
    }
    return comment
}
