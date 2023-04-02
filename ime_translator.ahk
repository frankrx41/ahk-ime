ImeTranslatorInitialize()
{
    global ime_translator_result_const
    global ime_translator_result_filtered
    global ime_translator_radical_list

    ImeTranslatorClear()
}

ImeTranslatorClear()
{
    global ime_translator_result_const      := []
    global ime_translator_result_filtered   := []
    global ime_translator_radical_list      := []
}

ImeTranslatorUpdateResult(splitted_input, radical_list)
{
    local
    global ime_translator_result_const
    global ime_translator_radical_list

    if( splitted_input )
    {
        ImeProfilerBegin(30)
        ime_translator_radical_list := radical_list
        ime_translator_result_const := []

        test_splitted_string := splitted_input
        loop % radical_list.Length()
        {
            find_split_string := SplittedInputGetPrevWords(test_splitted_string)
            if( find_split_string && !EscapeCharsIsMark(SubStr(find_split_string, 1, 1)) )
            {
                ; Get translate result
                translate_result := PinyinGetTranslateResult(find_split_string)
                if( translate_result.Length() == 0 ){
                    first_word := SplittedInputGetFirstWord(find_split_string)
                    translate_result := [[first_word, first_word]]
                }
            } else {
                ; Add legacy text
                find_split_string := EscapeCharsGetContent(find_split_string)
                translate_result := [[find_split_string, find_split_string, 0, "", 1]]
                if( RegexMatch(find_split_string, "^\s+$") ) {
                    translate_result[1,2] := ""
                }
            }
            ; Insert result
            ime_translator_result_const.Push(translate_result)
            test_splitted_string := SplittedInputRemoveFirstWord(test_splitted_string)
        }
        ImeProfilerEnd(30)
        ImeTranslatorFilterResults()
    } else {
        ImeTranslatorClear()
    }
}

ImeTranslatorFindMaxLengthResultIndex(split_index, max_length)
{
    local
    loop % ImeTranslatorResultGetListLength(split_index)
    {
        test_len := ImeTranslatorResultGetLength(split_index, A_Index)
        if( test_len <= max_length )
        {
            return A_Index
        }
    }
    return 0
}

ImeTranslatorFindPossibleMaxLength(split_index, ByRef next_words)
{
    local
    ; `max_length` = this word until next unlock word
    if( ImeSelectorIsSelectLock(split_index) )
    {
        max_length := ImeTranslatorResultGetLength(split_index, 1)
    }
    else
    {
        max_length := 1
        loop % ImeTranslatorResultGetLength(split_index, 1)-1
        {
            check_index := split_index + A_Index
            if( ImeSelectorIsSelectLock(check_index) ) {
                ; TODO: fill next_words
                next_words := "???"
                break
            }
            max_length += 1
        }
    }
    return max_length
}

ImeTranslatorFixupSelectIndex()
{
    local
    global ime_translator_result_filtered

    debug_info := ""
    ImeProfilerBegin(32, true)
    skip_word_count := 0
    loop % ime_translator_result_filtered.Length()
    {
        split_index := A_Index

        origin_select_index := ImeSelectorGetSelectIndex(split_index)
        select_index := !origin_select_index ? 0 : origin_select_index

        if( select_index ) {
            select_word_length := ImeTranslatorResultGetLength(split_index, select_index)
        } else {
            select_word_length := 0
        }
        select_is_lock := ImeSelectorIsSelectLock(split_index)

        ; `max_length` = this word until next unlock word
        max_length := ImeTranslatorFindPossibleMaxLength(split_index, next_words)

        debug_info .= "`n  - [" split_index "] "
        debug_info .= "skip: " skip_word_count ", lock: " select_is_lock ", max_len: " max_length " "

        if( skip_word_count )
        {
            Assert( !ImeSelectorIsSelectLock(split_index) )
            select_index := 0
            skip_word_count -= 1
        }
        else
        if( select_is_lock )
        {
            lock_word := ImeSelectorGetLockWord(split_index)
            ; TODO: use `lock_length`
            lock_length := ImeSelectorGetLockLength(split_index)
            select_index := ImeTranslatorResultFindIndex(split_index, lock_word, max_length)
            Assert(select_index, lock_word)
            ; Assert(ImeTranslatorResultGetLength(split_index, select_index) >= lock_length)
        }
        else
        {
            ; Find a result the no longer than `max_length`
            if( select_index == 0 || select_word_length > max_length )
            {
                select_index := ImeTranslatorFindMaxLengthResultIndex(split_index, max_length)
            }
        }

        if( origin_select_index != select_index )
        {
            ImeSelectorSetSelectIndex(split_index, select_index)
        }

        debug_info .= "[" origin_select_index "]->[" select_index "] "
        if( select_index )
        {
            select_word_length := ImeTranslatorResultGetLength(split_index, select_index)
            skip_word_count := select_word_length-1
            debug_info .= "skip: " skip_word_count " "
        }
    }
    ImeProfilerEnd(32, debug_info)
    Assert(skip_word_count == 0, skip_word_count)
}

ImeTranslatorFilterResults(single_mode:=false)
{
    local
    global ime_translator_result_const
    global ime_translator_radical_list
    global ime_translator_result_filtered

    search_result := CopyObj(ime_translator_result_const)
    radical_list := CopyObj(ime_translator_radical_list)
    skip_word := 0
    ImeProfilerBegin(31, true)
    loop % search_result.Length()
    {
        split_index := A_Index
        test_result := search_result[split_index]
        
        if( true ){
            ; PinyinResultFilterZeroWeight(test_result)
        }
        if( radical_list ){
            PinyinResultFilterByRadical(test_result, radical_list)
            radical_list.RemoveAt(1)
        }
        if( single_mode ){
            PinyinResultFilterSingleWord(test_result)
        }
        if( true ){
            PinyinResultUniquify(test_result)
        }
    }

    ; Store last select
    store_select_index := []
    loop % search_result.Length()
    {
        store_select_index[A_Index] := ime_translator_result_filtered[A_Index, 0]
    }
    ime_translator_result_filtered := search_result
    loop % search_result.Length()
    {
        ime_translator_result_filtered[A_Index, 0] := store_select_index[A_Index]
    }
    ImeTranslatorFixupSelectIndex()
    ImeProfilerEnd(31, "length: [" search_result.Length() "]")
}

;*******************************************************************************
; [1:"我爱你", 2:"我爱", 3:"我"]
; find ["我"]
;   - max_length == 1 return 3
;   - max_length == 2 return 2
; find ["你"]
;   return 0
ImeTranslatorResultFindIndex(split_index, find_words, max_length)
{
    local
    global ime_translator_result_filtered
    find_word_len := StrLen(find_words)
    loop, % ImeTranslatorResultGetListLength(split_index)
    {
        select_index := A_Index
        test_result := ImeTranslatorResultGetWord(split_index, select_index)
        if( StrLen(test_result) <= max_length && find_words == SubStr(test_result, 1, find_word_len) ){
            return select_index
        }
    }
    return 0
}

;*******************************************************************************
;
ImeTranslatorGetWordCount()
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered.Length()
}

;*******************************************************************************
;
ImeTranslatorResultGetListLength(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index].Length()
}

ImeTranslatorResultGetPinyin(split_index, word_index)
{
    ; Assert(word_index > 0 && word_index <= ImeTranslatorResultGetListLength(split_index))
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 1]
}

ImeTranslatorResultGetWord(split_index, word_index)
{
    ; Assert(word_index > 0 && word_index <= ImeTranslatorResultGetListLength(split_index))
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 2]
}

ImeTranslatorResultGetWeight(split_index, word_index)
{
    ; Assert(word_index > 0 && word_index <= ImeTranslatorResultGetListLength(split_index))
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 3]
}

ImeTranslatorResultGetComment(split_index, word_index)
{
    ; Assert(word_index > 0 && word_index <= ImeTranslatorResultGetListLength(split_index))
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 4]
}

ImeTranslatorResultGetLength(split_index, word_index)
{
    ; Assert(word_index > 0 && word_index <= ImeTranslatorResultGetListLength(split_index))
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 5]
}

;*******************************************************************************
;
ImeTranslatorResultGetFormattedComment(split_index, word_index)
{
    comment := ImeTranslatorResultGetComment(split_index, word_index)
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
