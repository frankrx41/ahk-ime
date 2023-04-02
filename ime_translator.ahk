ImeTranslatorInitialize()
{
    global ime_translator_result_list_origin
    global ime_translator_result_list_filtered
    ImeTranslatorClear()
}

ImeTranslatorClear()
{
    global ime_translator_result_list_origin    := []
    global ime_translator_result_list_filtered  := []
}

ImeTranslatorUpdateResult(splitter_result)
{
    local
    global ime_translator_result_list_origin
    global ime_translator_result_list_filtered

    if( splitter_result.Length() )
    {
        ImeProfilerBegin(30)
        ime_translator_result_list_origin := []
        radical_list := []
        debug_text := "["
        loop % splitter_result.Length()
        {
            radical_list.Push(SplitterResultGetRadical(splitter_result, A_Index))
            find_split_string := SplitterResultConvertToStringUntilSkip(splitter_result, A_Index)
            debug_text .= """" find_split_string ""","
            if( SplitterResultIsSkip(splitter_result, A_Index) )
            {
                ; Add legacy text
                translate_result := [[find_split_string, find_split_string, 0, "", 1]]
                if( RegexMatch(find_split_string, "^\s+$") ) {
                    translate_result[1,2] := ""
                }
            }
            else
            {
                Assert(find_split_string)
                ; Get translate result
                translate_result := PinyinTranslateFindResult(find_split_string)
                if( translate_result.Length() == 0 ){
                    first_word := SplitterResultConvertToString(splitter_result, A_Index)
                    translate_result := [[first_word, first_word, 0, "", 1]]
                }
            }
            ; Insert result
            ime_translator_result_list_origin.Push(translate_result)
        }
        debug_text := SubStr(debug_text, 1, StrLen(debug_text) - 1) . "]"
        ImeProfilerEnd(30, debug_text)
        ime_translator_result_list_filtered := TranslatorResultListFilterResults(ime_translator_result_list_origin, radical_list)
        ImeTranslatorFixupSelectIndex()
    } else {
        ImeTranslatorClear()
    }
}

;*******************************************************************************
;
ImeTranslatorFindMaxLengthResultIndex(split_index, max_length)
{
    local
    loop % ImeTranslatorResultListGetListLength(split_index)
    {
        test_len := ImeTranslatorResultListGetWordLength(split_index, A_Index)
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
        max_length := ImeTranslatorResultListGetWordLength(split_index, 1)
    }
    else
    {
        max_length := 1
        loop % ImeTranslatorResultListGetWordLength(split_index, 1)-1
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
    global ime_translator_result_list_filtered

    debug_info := ""
    ImeProfilerBegin(32, true)
    skip_word_count := 0
    loop % ime_translator_result_list_filtered.Length()
    {
        split_index := A_Index

        origin_select_index := ImeSelectorGetSelectIndex(split_index)
        select_index := !origin_select_index ? 0 : origin_select_index

        if( select_index ) {
            select_word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)
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
            ; Assert(ImeTranslatorResultListGetWordLength(split_index, select_index) >= lock_length)
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
            select_word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)
            skip_word_count := select_word_length-1
            debug_info .= "skip: " skip_word_count " "
        }
    }
    ImeProfilerEnd(32, debug_info)
    Assert(skip_word_count == 0, skip_word_count)
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
    global ime_translator_result_list_filtered
    find_word_len := StrLen(find_words)
    loop, % ImeTranslatorResultListGetListLength(split_index)
    {
        select_index := A_Index
        test_result := ImeTranslatorResultListGetWord(split_index, select_index)
        if( StrLen(test_result) <= max_length && find_words == SubStr(test_result, 1, find_word_len) ){
            return select_index
        }
    }
    return 0
}

;*******************************************************************************
;
ImeTranslatorResultListGetLength()
{
    global ime_translator_result_list_filtered
    return ime_translator_result_list_filtered.Length()
}

;*******************************************************************************
;
ImeTranslatorResultListGetListLength(split_index)
{
    global ime_translator_result_list_filtered
    return ime_translator_result_list_filtered[split_index].Length()
}

ImeTranslatorResultListGetPinyin(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetPinyin(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWord(split_index, word_index)
{
    global ime_translator_result_list_filtered
    ImeProfilerBegin(1)
    ImeProfilerEnd(1, split_index "," word_index)
    return TranslatorResultGetWord(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWeight(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetWeight(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetComment(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetComment(ime_translator_result_list_filtered[split_index], word_index)
}

ImeTranslatorResultListGetWordLength(split_index, word_index)
{
    global ime_translator_result_list_filtered
    return TranslatorResultGetWordLength(ime_translator_result_list_filtered[split_index], word_index)
}

;*******************************************************************************
;
ImeTranslatorResultGetFormattedComment(split_index, word_index)
{
    comment := ImeTranslatorResultListGetComment(split_index, word_index)
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
