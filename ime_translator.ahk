ImeTranslatorClear()
{
    global ime_translator_result_const      := []
    global ime_translator_result_filtered   := []
    global ime_translator_radical_list      := ""
    global ime_translator_input_string      := ""
    global ime_translator_input_split       := ""
    global ime_translator_split_indexs      := []
}

ImeTranslatorUpdateInputString(input_string)
{
    local
    global DB
    global ime_translator_result_const
    global ime_translator_input_string
    global ime_translator_input_split
    global ime_translator_split_indexs
    global ime_translator_radical_list

    input_string := LTrim(input_string, " ")
    if( input_string )
    {
        ime_translator_input_string := input_string
        split_indexs := []

        ime_translator_input_split := PinyinSplit(ime_translator_input_string, split_indexs, radical_list)
        ime_translator_split_indexs := split_indexs
        ime_translator_radical_list := radical_list

        ime_translator_result_const := []
        test_split_string := ime_translator_input_split
        loop % split_indexs.Length()
        {
            find_split_string := SplitWordGetPrevWords(test_split_string)
            if( find_split_string && !EscapeCharsIsMark(SubStr(find_split_string, 1, 1)) )
            {
                translate_result := PinyinGetTranslateResult(find_split_string, DB)
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

ImeTranslatorGetPosSplitIndex(caret_pos)
{
    global ime_translator_split_indexs
    global ime_input_string
    if( ime_translator_split_indexs.Length() >= 1)
    {
        if( ime_translator_split_indexs[ime_translator_split_indexs.Length()] == caret_pos )
        {
            return ime_translator_split_indexs.Length()
        }
        loop % ime_translator_split_indexs.Length()
        {
            if( ime_translator_split_indexs[A_Index] > caret_pos ){
                return A_Index
            }
        }
        Assert(false, ime_input_string "," caret_pos)
    }
    return 1
}

ImeTranslatorFixupSelectIndex()
{
    global ime_translator_result_filtered
    search_result := ime_translator_result_filtered

    skip_word := 0
    loop % search_result.Length()
    {
        split_index := A_Index

        if( skip_word )
        {
            ImeTranslatorResultSetSelectIndex(split_index, 0, false)
            skip_word -= 1
        }
        else
        {
            select_index := ImeTranslatorResultGetSelectIndex(split_index)
            current_length := ImeTranslatorResultGetLength(split_index, select_index)
            if( ImeTranslatorResultIsLock(split_index) )
            {
                skip_word := current_length-1
            }
            else
            {
                max_length := 1
                loop % ImeTranslatorResultGetLength(split_index, 1)-1
                {
                    check_index := split_index + A_Index
                    if( ImeTranslatorResultIsLock(check_index) )
                    {
                        break
                    }
                    max_length += 1
                }

                ; Find a result the no longer than `max_length`
                if( select_index != 0 && current_length <= max_length )
                {
                    skip_word := current_length-1
                }
                else
                {
                    loop % ImeTranslatorResultGetListLength(split_index)
                    {
                        test_len := ImeTranslatorResultGetLength(split_index, A_Index)
                        if( test_len <= max_length )
                        {
                            ImeTranslatorResultSetSelectIndex(split_index, A_Index, false)
                            skip_word := test_len-1
                            break
                        }
                    }
                }
            }
        }
    }
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
    loop % search_result.Length()
    {
        test_result := search_result[A_Index]
        if( radical_list ){
            PinyinResultFilterByRadical(test_result, radical_list)
            radical_list.RemoveAt(1)
        }
        if( single_mode ){
            PinyinResultFilterSingleWord(test_result)
        }
        PinyinResultUniquify(test_result)
        ; if prev length > 1, this[0] := 0
        ; [select_index, lock]
        ; Can not use `ImeTranslatorResultSetSelectIndex`
        if( skip_word ) {
            test_result[0] := [0, false]
            skip_word -= 1
        }
        else {
            test_result[0] := [1, false]
            skip_word := test_result[1,5]-1
        }
    }
    ime_translator_result_filtered := search_result
}

ImeTranslatorGetOutputString()
{
    global ime_translator_result_filtered
    search_result := ime_translator_result_filtered

    result_string := ""
    loop % search_result.Length()
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

ImeTranslatorGetLastWordPos()
{
    global ime_translator_split_indexs
    if( ime_translator_split_indexs.Length() <= 1 ){
        return 0
    }
    return ime_translator_split_indexs[ime_translator_split_indexs.Length()-1]
}

ImeTranslatorGetLeftWordPos(start_index)
{
    local
    global ime_translator_split_indexs

    if( start_index == 0 ){
        return 0
    }
    last_index := 0
    loop, % ime_translator_split_indexs.Length()
    {
        split_index := ime_translator_split_indexs[A_Index]
        if( split_index >= start_index ){
            break
        }
        last_index := split_index
    }
    return last_index
}

ImeTranslatorGetRightWordPos(start_index)
{
    local
    global ime_translator_split_indexs

    last_index := start_index
    loop, % ime_translator_split_indexs.Length()
    {
        split_index := ime_translator_split_indexs[A_Index]
        if( split_index > start_index ){
            last_index := split_index
            break
        }
    }
    return last_index
}

ImeTranslatorResultSetSelectIndex(split_index, word_index, lock_select:=true)
{
    global ime_translator_result_filtered
    ime_translator_result_filtered[split_index, 0] := [word_index, lock_select]
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

ImeTranslatorGetWordCount()
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered.Length()
}

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
