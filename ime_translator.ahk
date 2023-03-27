ImeTranslatorClear()
{
    global translator_result_const          := []
    global translator_result_filtered       := []
    global translator_radical               := ""
    global translator_input_string          := ""
    global translator_input_split           := ""
    global translator_split_indexs          := []
}

ImeTranslatorUpdateInputString(input_string)
{
    local
    global DB
    global translator_result_const
    global translator_input_string
    global translator_input_split
    global translator_split_indexs

    input_string := LTrim(input_string, " ")
    if( input_string )
    {
        translator_input_string := input_string
        split_indexs := []
        Imetranslator_input_split := PinyinSplit(translator_input_string, split_indexs)
        translator_split_indexs := split_indexs
        translator_result_const := PinyinGetTranslateResult(translator_input_string, translator_input_split, DB)
        ImeTranslatorFilterResult()
    } else {
        translator_input_string := ""
    }
}

ImeTranslatorFilterResult(single_mode:=false)
{
    local
    global translator_result_const
    global translator_radical
    global translator_result_filtered

    search_result := CopyObj(translator_result_const)
    if( search_result )
    {
        if( translator_radical ){
            PinyinResultFilterByRadical(search_result, translator_radical)
        }
        if( single_mode ){
            PinyinResultFilterSingleWord(search_result)
        }
    }
    translator_result_filtered := search_result
    translator_result_filtered[0] := 1
}

ImeTranslatorUpdateInputRadical(radical)
{
    global translator_radical
    translator_radical := radical
    ImeTranslatorFilterResult()
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
    global translator_input_string

    send_word := ImeTranslatorGetWord(ImeTranslatorGetSelectIndex())
    pinyin_string := ImeTranslatorGetPinyin(ImeTranslatorGetSelectIndex())

    sent_string_len := ImeTranslatorGetSendLength(translator_input_string, pinyin_string)

    translator_input_string := SubStr(translator_input_string, sent_string_len+1)

    tooltip_debug[11] := "[" send_word "] " pinyin_string "," translator_input_string "," sent_string_len
    ImeTranslatorSetSelectIndex(1)
    ImeTranslatorUpdateInputString(translator_input_string)
    return send_word
}

ImeTranslatorGetLastWordPos()
{
    global translator_split_indexs
    if( translator_split_indexs.Length() <= 1 ){
        return 0
    }
    return translator_split_indexs[translator_split_indexs.Length()-1]
}

ImeTranslatorGetLeftWordPos(start_index)
{
    local
    global translator_split_indexs

    if( start_index == 0 ){
        return translator_split_indexs[translator_split_indexs.Length()]
    }
    last_index := 0
    loop, % translator_split_indexs.Length()
    {
        split_index := translator_split_indexs[A_Index]
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
    global translator_split_indexs

    last_index := 0
    loop, % translator_split_indexs.Length()
    {
        split_index := translator_split_indexs[A_Index]
        if( split_index > start_index ){
            last_index := split_index
            break
        }
    }
    return last_index
}

ImeTranslatorGetSelectIndex()
{
    global translator_result_filtered
    return translator_result_filtered[0]
}
ImeTranslatorSetSelectIndex(index)
{
    global translator_result_filtered
    translator_result_filtered[0] := Max(1, Min(ImeTranslatorGetListLength(), index))
}

ImeTranslatorGetListLength()
{
    global translator_result_filtered
    return translator_result_filtered.Length()
}
ImeTranslatorGetRemainString()
{
    global translator_input_string
    return translator_input_string
}

ImeTranslatorGetDebugInfo(index)
{
    global translator_result_filtered
    return translator_result_filtered[index, 0]
}
ImeTranslatorGetPinyin(index)
{
    global translator_result_filtered
    return translator_result_filtered[index, 1]
}

ImeTranslatorGetWord(index)
{
    global translator_result_filtered
    return translator_result_filtered[index, 2]
}

ImeTranslatorGetWeight(index)
{
    global translator_result_filtered
    return translator_result_filtered[index, 3]
}

ImeTranslatorGetComment(index)
{
    global translator_result_filtered
    return translator_result_filtered[index, 4]
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
    global translator_result_filtered
    return translator_result_filtered[index, 6]
}
ImeTranslatorGetInputRadical()
{
    global translator_radical
    return translator_radical
}
