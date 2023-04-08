;*******************************************************************************
; translator_result := []
;   [1]: "wo3"      ; pinyin
;   [2]: "我"       ; value
;   [3]: 30233      ; weight
;   [4]: ""         ; comment
;   [5]: 1          ; word length
;
TranslatorResultGetPinyin(ByRef translate_result, word_index)
{
    return translate_result[word_index, 1]
}

TranslatorResultGetWord(ByRef translate_result, word_index)
{
    return translate_result[word_index, 2]
}

TranslatorResultSetWord(ByRef translate_result, word_index, word)
{
    translate_result[word_index, 2] := word
}

TranslatorResultGetWeight(ByRef translate_result, word_index)
{
    return translate_result[word_index, 3]
}

TranslatorResultGetComment(ByRef translate_result, word_index)
{
    return translate_result[word_index, 4]
}

TranslatorResultSetComment(ByRef translate_result, word_index, comment)
{
    translate_result[word_index, 4] := comment
}

TranslatorResultGetWordLength(ByRef translate_result, word_index)
{
    return translate_result[word_index, 5]
}

;*******************************************************************************
;
TranslatorSingleResultGetWeight(ByRef single_result)
{
    return single_result[3]
}

TranslatorSingleResultSetWeight(ByRef single_result, weight)
{
    single_result[3] := weight
}

;*******************************************************************************
; [1:"我爱你", 2:"我爱", 3:"我"]
; find ["我"]
;   - max_length == 1 return 3
;   - max_length == 2 return 2
; find ["你"]
;   return 0
TranslatorResultListFindIndex(ByRef translate_result_list, split_index, find_words, max_length)
{
    local
    find_word_len := StrLen(find_words)
    debug_text := ImeProfilerBegin(45)
    debug_text .= split_index "," translate_result_list[split_index].Length()
    select_index := 0
    loop, % translate_result_list[split_index].Length()
    {
        select_index := A_Index
        test_result := TranslatorResultGetWord(translate_result_list[split_index], select_index)
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
TranslatorResultListFilterResults(ByRef translate_result_list, input_radical_list, single_mode:=false)
{
    local
    result_list     := CopyObj(translate_result_list)
    radical_list    := CopyObj(input_radical_list)

    debug_text := ""
    ImeProfilerBegin(31)
    loop % result_list.Length()
    {
        split_index := A_Index
        test_result := result_list[split_index]
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
    ImeProfilerEnd(31, "[" result_list.Length() "]: " . debug_text)
    return result_list
}

;*******************************************************************************
; Sort
TranslatorResultSortByWeight(ByRef translate_result)
{
    translate_result := ObjectSort(translate_result, 3,, true)
}
