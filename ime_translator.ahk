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

        if( StrLen(ime_translator_input_string) == 1 && !InStr("aloe", ime_translator_input_string) )
        {
            search_result := []
            search_result[1] := [ime_translator_input_string, ime_translator_input_string, "N/A"]
            ime_translator_result_const := search_result
        }
        else
        {
            ime_translator_input_split := PinyinSplit(ime_translator_input_string, split_indexs, radical_list)
            ime_translator_split_indexs := split_indexs
            ime_translator_radical_list := radical_list

            ime_translator_result_const := []
            test_split_string := ime_translator_input_split
            loop % SplitWordGetWordCount(ime_translator_input_split)
            {
                translate_result := PinyinGetTranslateResult(test_split_string, DB)
                ime_translator_result_const.Push(translate_result)
                test_split_string := SplitWordRemoveFirstWord(test_split_string)
            }
        }
        ImeTranslatorFilterResult()
    } else {
        ime_translator_input_string := ""
    }
}

ImeTranslatorGetPosSplitIndex(caret_pos)
{
    global ime_translator_split_indexs
    global ime_input_string
    if( ime_translator_split_indexs.Length() >= 1)
    {
        loop % ime_translator_split_indexs.Length()
        {
            if( ime_translator_split_indexs[A_Index] >= caret_pos ){
                return A_Index
            }
        }
        Assert(false, ime_input_string "," caret_pos)
    }
    return 1
}

ImeTranslatorFilterResult(single_mode:=false)
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
        ; if prev length > 1, this[0] := 0
        if( skip_word ) {
            test_result[0] := 0
        }
        else {
            test_result[0] := 1
            skip_word := test_result[1,5]-1
        }
    }
    ime_translator_result_filtered := search_result
}

ImeTranslatorGetSendLength(full_input_string, send_pinyin_string)
{
    local
    index_pinyin    := 1
    index_input     := 1
    sent_string_len := 0
    sent_pinyin_len := StrLen(send_pinyin_string)
    ; "wohenxihuanni" - "wo'hen" = "xihuanni"
    loop, Parse, % full_input_string
    {
        match := false
        if( index_pinyin > sent_pinyin_len ){
            break
        }
        loop
        {
            input_char := SubStr(full_input_string, index_input, 1)
            if( input_char == " " ){
                index_input += 1
                sent_string_len += 1
            } else {
                break
            }
        }
        loop
        {
            pinyin_char := SubStr(send_pinyin_string, index_pinyin, 1)
            if( pinyin_char == input_char ){
                match := true
                break
            }
            if( input_char == "1" && pinyin_char == "5" ){
                match := true
                break
            }
            if( pinyin_char == "" ) {
                break
            }
            index_pinyin += 1
        }
        sent_string_len += match ? 1 : 0
        index_pinyin    += 1
        index_input     += 1
    }
    return sent_string_len
}

ImeTranslatorSendWordThenUpdate()
{
    global tooltip_debug
    global ime_translator_input_string

    split_index := 1
    send_word := ImeTranslatorGetWord(split_index, ImeTranslatorGetSelectIndex(split_index))
    pinyin_string := ImeTranslatorGetPinyin(split_index, ImeTranslatorGetSelectIndex(split_index))

    sent_string_len := ImeTranslatorGetSendLength(ime_translator_input_string, pinyin_string)

    ime_translator_input_string := SubStr(ime_translator_input_string, sent_string_len+1)

    tooltip_debug[11] := "[" send_word "] " pinyin_string "," ime_translator_input_string "," sent_string_len
    ImeTranslatorSetSelectIndex(1, 1)
    ImeTranslatorUpdateInputString(ime_translator_input_string)
    return send_word
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
        return ime_translator_split_indexs[ime_translator_split_indexs.Length()]
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

    last_index := 0
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

ImeTranslatorGetSelectIndex(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, 0]
}
ImeTranslatorSetSelectIndex(split_index, word_index)
{
    global ime_translator_result_filtered
    ime_translator_result_filtered[split_index, 0] := Max(1, Min(ImeTranslatorGetListLength(split_index), word_index))
}

ImeTranslatorGetWordCount()
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered.Length()
}

ImeTranslatorGetListLength(split_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index].Length()
}
ImeTranslatorGetRemainString()
{
    global ime_translator_input_string
    return ime_translator_input_string
}

ImeTranslatorGetPinyin(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 1]
}

ImeTranslatorGetWord(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 2]
}

ImeTranslatorGetWeight(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 3]
}

ImeTranslatorGetComment(split_index, word_index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[split_index, word_index, 4]
}

ImeTranslatorGetCommentDisplayText(split_index, word_index)
{
    comment := ImeTranslatorGetComment(split_index, word_index)
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
