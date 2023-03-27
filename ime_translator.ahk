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

        if( StrLen(ime_translator_input_string) == 1 && !InStr("aloe", ime_translator_input_string) )
        {
            search_result := []
            search_result[1] := [ime_translator_input_string, ime_translator_input_string, "N/A"]
            ime_translator_result_const := search_result
        }
        else
        {
            ime_translator_result_const := PinyinGetTranslateResult(ime_translator_input_split, DB)
        }
        ImeTranslatorFilterResult()
    } else {
        ime_translator_input_string := ""
    }
}

ImeTranslatorFilterResult(single_mode:=false)
{
    local
    global ime_translator_result_const
    global ime_translator_radical_list
    global ime_translator_result_filtered

    search_result := CopyObj(ime_translator_result_const)
    if( search_result )
    {
        if( ime_translator_radical_list ){
            PinyinResultFilterByRadical(search_result, ime_translator_radical_list)
        }
        if( single_mode ){
            PinyinResultFilterSingleWord(search_result)
        }
    }
    ime_translator_result_filtered := search_result
    ime_translator_result_filtered[0] := 1
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

    send_word := ImeTranslatorGetWord(ImeTranslatorGetSelectIndex())
    pinyin_string := ImeTranslatorGetPinyin(ImeTranslatorGetSelectIndex())

    sent_string_len := ImeTranslatorGetSendLength(ime_translator_input_string, pinyin_string)

    ime_translator_input_string := SubStr(ime_translator_input_string, sent_string_len+1)

    tooltip_debug[11] := "[" send_word "] " pinyin_string "," ime_translator_input_string "," sent_string_len
    ImeTranslatorSetSelectIndex(1)
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

ImeTranslatorGetSelectIndex()
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[0]
}
ImeTranslatorSetSelectIndex(index)
{
    global ime_translator_result_filtered
    ime_translator_result_filtered[0] := Max(1, Min(ImeTranslatorGetListLength(), index))
}

ImeTranslatorGetListLength()
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered.Length()
}
ImeTranslatorGetRemainString()
{
    global ime_translator_input_string
    return ime_translator_input_string
}

ImeTranslatorGetDebugInfo(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 0]
}
ImeTranslatorGetPinyin(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 1]
}

ImeTranslatorGetWord(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 2]
}

ImeTranslatorGetWeight(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 3]
}

ImeTranslatorGetComment(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 4]
}

ImeTranslatorGetCommentDisplayText(index)
{
    comment := ImeTranslatorGetComment(index)
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

ImeTranslatorGetIndexWordRadical(index)
{
    global ime_translator_result_filtered
    return ime_translator_result_filtered[index, 6]
}
