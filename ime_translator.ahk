ImeTranslatorInitialize()
{
    ImeTranslatorClear()
}

ImeTranslatorClear()
{
    global ime_translator_result_const      := []
    global ime_translator_result_filtered   := []
    global ime_translator_radical_list      := []
}

ImeTranslatorUpdateResult(input_split, radical_list)
{
    local
    global ime_translator_result_const
    global ime_translator_radical_list

    if( input_split )
    {
        ImeProfilerBegin(30)
        ime_translator_radical_list := radical_list
        ime_translator_result_const := []

        test_split_string := input_split
        loop % radical_list.Length()
        {
            find_split_string := SplitWordGetPrevWords(test_split_string)
            if( find_split_string && !EscapeCharsIsMark(SubStr(find_split_string, 1, 1)) )
            {
                translate_result := PinyinGetTranslateResult(find_split_string, ImeDBGet())
                if( translate_result.Length() == 0 ){
                    first_word := SplitWordGetFirstWord(find_split_string)
                    translate_result := [[first_word, first_word]]
                }
            } else {
                find_split_string := EscapeCharsGetContent(find_split_string)
                if( !RegexMatch(find_split_string, "^\s+$") ) {
                    translate_result := [[find_split_string, find_split_string]]
                } else {
                    translate_result := [[find_split_string, ""]]
                }
            }
            ime_translator_result_const.Push(translate_result)
            test_split_string := SplitWordRemoveFirstWord(test_split_string)
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
    return max_length
}

ImeTranslatorFixupSelectIndex()
{
    local
    global ime_translator_result_filtered

    debug_info := ""
    ImeProfilerBegin(32, true)
    skip_word_count := 0
    skip_words := ""
    loop % ime_translator_result_filtered.Length()
    {
        split_index := A_Index
        debug_info .= "`n  - (" skip_word_count ") "

        select_index := ImeSelectorGetSelectIndex(split_index)
        select_index := !select_index ? 0 : select_index
        if( select_index ) {
            select_word_length := ImeTranslatorResultGetLength(split_index, select_index)
        } else {
            select_word_length := 0
        }
        select_is_lock := ImeSelectorIsSelectLock(split_index)

        ; `max_length` = this word until next unlock word
        max_length := ImeTranslatorFindPossibleMaxLength(split_index, next_words)

        if( skip_word_count )
        {
            Assert( !ImeSelectorIsSelectLock(split_index) )
            select_index := 0
            skip_word_count -= 1
            skip_words := SubStr(skip_words, 2)
        }
        else
        if( select_is_lock )
        {
            lock_word := ImeSelectorGetLockWord(split_index)
            ; TODO: use `lock_length`
            lock_length := ImeSelectorGetLockLength(split_index)
            select_index := ImeTranslatorResultFindIndex(split_index, select_word, max_length)
            Assert(select_index)
            Assert(ImeTranslatorResultGetLength(split_index, select_index) >= lock_length)
        }
        else
        {
            ; Find a result the no longer than `max_length`
            if( select_index == 0 || select_word_length > max_length )
            {
                select_index := ImeTranslatorFindMaxLengthResultIndex(split_index, max_length)
            }
        }

        ImeSelectorSetSelectIndex(split_index, select_index)

        if( select_index )
        {
            select_word := ImeTranslatorResultGetWord(split_index, select_index)
            select_word_length := ImeTranslatorResultGetLength(split_index, select_index)
            skip_word_count := select_word_length-1
            skip_words .= SubStr(select_word, 2)
            first_select_word := SubStr(select_word, 1, 1)
        }

        debug_info .= "[" split_index "]->[" select_index "]+""" first_select_word """+[" skip_words "(" skip_word_count ")]"
    }
    ImeProfilerEnd(32, debug_info)
    Assert(StrLen(skip_words) == 0, skip_words "(" Asc(skip_words) ")")
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
