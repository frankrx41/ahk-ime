;*******************************************************************************
;
TranslatorResultGetPinyin(ByRef translator_result, word_index)
{
    return translator_result[word_index, 1]
}

TranslatorResultGetWord(ByRef translator_result, word_index)
{
    return translator_result[word_index, 2]
}

TranslatorResultGetWeight(ByRef translator_result, word_index)
{
    return translator_result[word_index, 3]
}

TranslatorResultGetComment(ByRef translator_result, word_index)
{
    return translator_result[word_index, 4]
}

TranslatorResultGetWordLength(ByRef translator_result, word_index)
{
    return translator_result[word_index, 5]
}

;*******************************************************************************
;
TranslatorResultListFindPossibleMaxLength(ByRef translator_result, split_index)
{
    local
    ; `max_length` = this word until next unlock word
    ; TODO: Fix
    if( ImeSelectorIsSelectLock(split_index) )
    {
        max_length := TranslatorResultGetWordLength(translator_result, 1)
    }
    else
    {
        max_length := 1
        loop % TranslatorResultGetWordLength(translator_result, 1)-1
        {
            check_index := split_index + A_Index
            if( ImeSelectorIsSelectLock(check_index) ) {
                break
            }
            max_length += 1
        }
    }
    return max_length
}

TranslatorResultListFindMaxLengthResultIndex(ByRef translator_result, split_index, max_length)
{
    local
    loop % translator_result[split_index].Length()
    {
        test_len := TranslatorResultGetWordLength(translator_result[A_Index], A_Index)
        if( test_len <= max_length )
        {
            return A_Index
        }
    }
    return 0
}

;*******************************************************************************
; [1:"我爱你", 2:"我爱", 3:"我"]
; find ["我"]
;   - max_length == 1 return 3
;   - max_length == 2 return 2
; find ["你"]
;   return 0
TranslatorResultListFindIndex(ByRef translator_result, split_index, find_words, max_length)
{
    local
    find_word_len := StrLen(find_words)
    ImeProfilerBegin(45)
    debug_text := split_index "," translator_result[split_index].Length()
    select_index := 0
    loop, % translator_result[split_index].Length()
    {
        select_index := A_Index
        test_result := TranslatorResultGetWord(translator_result[split_index], select_index)
        if( StrLen(test_result) <= max_length && find_words == SubStr(test_result, 1, find_word_len) ){
            debug_text .= "`n  - [" select_index "] -> """ find_words """ == """ test_result """"
            break
        }
    }
    ImeProfilerEnd(45, debug_text)
    return select_index
}

;*******************************************************************************
;
TranslatorResultListFilterResults(ByRef translator_result_list, input_radical_list, single_mode:=false)
{
    local
    search_result   := CopyObj(translator_result_list)
    radical_list    := CopyObj(input_radical_list)

    debug_text := ""
    ImeProfilerBegin(31, true)
    loop % search_result.Length()
    {
        split_index := A_Index
        test_result := search_result[split_index]
        debug_text .= "`n  - [" split_index "] (" test_result.Length() ")"
        if( true ){
            ; TranslatorResultFilterZeroWeight(test_result)
        }
        if( radical_list ){
            TranslatorResultFilterByRadical(test_result, radical_list)
            radical_list.RemoveAt(1)
        }
        if( single_mode ){
            TranslatorResultFilterSingleWord(test_result)
        }
        if( true ){
            TranslatorResultUniquify(test_result)
        }
        debug_text .= " -> (" test_result.Length() ")"
    }

    ; ImeSelectorFixupSelectIndex()
    ImeProfilerEnd(31, "[" search_result.Length() "]: " . debug_text)
    return search_result
}
