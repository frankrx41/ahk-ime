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
        ImeTranslatorFilterResults()
    } else {
        ImeTranslatorClear()
    }
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

        if( skip_word_count )
        {
            skip_word := SubStr(skip_words, 1, 1)
            ImeTranslatorResultSetSelectIndex(split_index, 0, false, skip_word, 1)
            skip_word_count -= 1
            skip_words := SubStr(skip_words, 2)
            debug_info .= "`n  - Skp: [" split_index "]->[" 0 "]+""" skip_word """+[" skip_words "]"
        }
        else
        {
            select_index := ImeTranslatorResultGetSelectIndex(split_index)
            select_index := !select_index ? 0 : select_index
            current_length := ImeTranslatorResultGetLength(split_index, select_index)
            select_is_lock := ImeTranslatorResultIsLock(split_index)
            if( !select_is_lock )
            {
                ; `max_length` = this word until next unlock word
                max_length := 1
                loop % ImeTranslatorResultGetLength(split_index, 1)-1
                {
                    check_index := split_index + A_Index
                    if( ImeTranslatorResultIsLock(check_index) ) {
                        break
                    }
                    max_length += 1
                }

                ; Find a result the no longer than `max_length`
                if( select_index == 0 || current_length > max_length )
                {
                    loop % ImeTranslatorResultGetListLength(split_index)
                    {
                        test_len := ImeTranslatorResultGetLength(split_index, A_Index)
                        if( test_len <= max_length )
                        {
                            select_index := A_Index
                            current_length := test_len
                            break
                        }
                    }
                }
            }

            ImeTranslatorResultSetSelectIndex(split_index, select_index, select_is_lock) 
            select_word := ImeTranslatorResultGetWord(split_index, select_index)
            skip_word_count := current_length-1
            skip_words .= SubStr(select_word, 2)
            first_select_word := SubStr(select_word, 1, 1)
            debug_info .= "`n  - Set: [" split_index "]->[" select_index "]+""" first_select_word """+[" skip_words "(" skip_word_count ")]"
        }
    }
    ImeProfilerEnd(32, debug_info)
    Assert(StrLen(skip_words) == 0, Asc(skip_words),,true)
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

ImeTranslatorGetOutputString()
{
    global ime_translator_result_filtered

    result_string := ""
    loop % ime_translator_result_filtered.Length()
    {
        split_index := A_Index
        select_index := ImeTranslatorResultGetSelectIndex(split_index)
        if( select_index > 0 )
        {
            result_string .= ImeTranslatorResultGetWord(split_index, select_index)
        }
    }
    return result_string
}

;*******************************************************************************
; [split_index, 0] = select info
;   - 1: select index, work for selector menu, 0 mark not select, should skip this
;   - 2: is lock
;   - 3: value
;   - 4: length
ImeTranslatorResultSetSelectIndex(split_index, word_index, lock_select:=true, select_word:="", word_length:=0)
{
    local
    global ime_translator_result_filtered
    if( word_index != 0 && select_word == "" && word_length == 0 )
    {
        select_word := ImeTranslatorResultGetWord(split_index, word_index)
        word_length := ImeTranslatorResultGetLength(split_index, word_index)
    }
    ime_translator_result_filtered[split_index, 0] := [word_index, lock_select, select_word, word_length]
}

ImeTranslatorResultGetSelectIndex(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, 0, 1]
}

ImeTranslatorResultIsLock(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, 0, 2]
}

ImeTranslatorResultGetSelectWord(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, 0, 3]
}

ImeTranslatorResultGetSelectLength(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, 0, 4]
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
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 1]
}

ImeTranslatorResultGetWord(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 2]
}

ImeTranslatorResultGetWeight(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 3]
}

ImeTranslatorResultGetComment(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 4]
}

ImeTranslatorResultGetLength(split_index, word_index)
{
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
