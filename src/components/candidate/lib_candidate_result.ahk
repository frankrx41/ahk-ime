;*******************************************************************************
; Candidate
;   ["splitted_list"]: splitted_list
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
    return TranslatorResultGetTraditionalLevel(candidata[split_index, word_index]) > 0
}

; 0 false 1 trad 2 auto trad
CandidateGetTraditionalLevel(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetTraditionalLevel(candidata[split_index, word_index])
}

CandidateGetTopLevel(ByRef candidata, split_index, word_index)
{
    return TranslatorResultGetTopLevel(candidata[split_index, word_index])
}

CandidateIsDisable(ByRef candidata, split_index, word_index)
{
    return TranslatorResultIsDisable(candidata[split_index, word_index])
}

CandidateGetMaxWordLength(ByRef candidata, split_index)
{
    return TranslatorResultGetWordLength(candidata[split_index, 1])
}

;*******************************************************************************
; [1:"我爱你", 2:"我爱", 3:"我"]
; find ["我"]
;   - max_length == 1 return 3
;   - max_length == 2 return 2
; find ["你"]
;   return 0
CandidateFindWordSelectIndex(ByRef candidate, split_index, find_words)
{
    local
    find_word_len := StrLen(find_words)
    max_length := find_word_len

    ImeProfilerBegin()
    debug_text := split_index "," candidate[split_index].Length()
    select_index := 0
    loop, % candidate[split_index].Length()
    {
        select_index := A_Index
        test_word := TranslatorResultGetWord(candidate[split_index, select_index])
        test_word_length := TranslatorResultGetWordLength(candidate[split_index, select_index])
        if( test_word_length <= max_length && find_words == SubStr(test_word, 1, find_word_len) ){
            debug_text .= "[" select_index "] -> """ find_words """ == """ test_word """"
            break
        }
    }
    ImeProfilerEnd(debug_text)
    return select_index
}

CandidateFindMaxLengthSelectIndex(ByRef candidate, split_index, max_length, tyr_first_word, ByRef out_weight:=0)
{
    local
    select_index := 0
    max_weight := -1
    test_max_length := 0
    loop % candidate[split_index].Length()
    {
        translator_result := candidate[split_index, A_Index]
        test_len := TranslatorResultGetWordLength(translator_result)
        if( ( test_max_length == 0 && test_len <= max_length ) || test_len == test_max_length)
        {
            if( test_max_length == 0 ){
                test_max_length := test_len
            }
            weight := TranslatorResultGetWeight(translator_result)
            max_weight := weight
            select_index := A_Index
            break
            ; weight := TranslatorResultGetWeight(translator_result)
            ; if( test_len == 1 ) {
            ;     word := TranslatorResultGetWord(translator_result)
            ;     if( IsPreposition(word) ){
            ;         weight += 5000.4
            ;     }
            ;     if( tyr_first_word && (IsFirstWord(word) || IsVerb(word)) ) {
            ;         weight += 7500.1
            ;     }
            ;     if( !tyr_first_word && IsLastWord(word) ) {
            ;         weight += 10000.2
            ;     }
            ; }
            ; if( max_weight < weight ){
            ;     max_weight := weight
            ;     select_index := A_Index
            ; }
            ; if( weight < max_length - 12000 ) {
            ;     break
            ; }
        }
    }
    out_weight := max_weight
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
    ImeProfilerBegin()
    loop % result_list.Length()
    {
        split_index := A_Index
        test_result := result_list[split_index]
        debug_text .= "[" split_index  ", " CandidateGetLegacyPinyin(result_list, split_index, 1) "] (" test_result.Length() ")"
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
    ImeProfilerEnd("[" result_list.Length() "]: " . debug_text)
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
    trad_level := CandidateGetTraditionalLevel(candidata, split_index, word_index)
    if( trad_level == 1 ) {
        comment := "*" . comment
    }
    if( trad_level == 2 ) {
        comment := "?" . comment
    }
    top_level := CandidateGetTopLevel(candidata, split_index, word_index)
    if( top_level > 0 ) {
        comment := "^" . top_level . comment
    }
    return comment
}
