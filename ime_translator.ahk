; class Translator
; {
;     __New() {
;         TranslatorClear()
;     }

TranslatorClear()
{
    global translator_result_const
    global translator_result_const
    global translator_radical
    global translator_single_mode
    global translator_candidate_filtered
    global translator_input_string
    global translator_input_split
    global translator_split_indexs
    global translator_candidate_origin
    translator_result_const := []
    translator_radical      := ""
    translator_input_string   := ""
    translator_input_split    := ""
    translator_split_indexs   := []
    translator_single_mode    := false
    global translator_select_index
    translator_select_index := 0
    translator_candidate_filtered := []
}

TranslatorUpdateInputString(input_string)
{
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    local
    global DB
    input_string := LTrim(input_string, " ")

    global translator_result_const
    global translator_radical
    global translator_single_mode
    global translator_candidate_filtered
    global translator_input_string
    global translator_input_split
    global translator_split_indexs
    global translator_candidate_origin

    if( input_string )
    {
        translator_input_string := input_string
        split_indexs := []
        translator_input_split := PinyinSplit(translator_input_string, split_indexs)
        translator_split_indexs := split_indexs
        translator_result_const := PinyinGetTranslateResult(translator_input_string, translator_input_split, DB)
        TranslatorFilterResult()
    } else {
        translator_input_string := ""
    }
}

TranslatorFilterResult()
{
    local
    global translator_result_const
    global translator_radical
    global translator_single_mode
    global translator_candidate_filtered
    search_result := CopyObj(translator_result_const)
    if( search_result )
    {
        if( translator_radical ){
            PinyinResultFilterByRadical(search_result, translator_radical)
        }
        if( translator_single_mode ){
            PinyinResultFilterSingleWord(search_result)
        }
    }
    translator_candidate_filtered := search_result
}

TranslatorUpdateInputRadical(radical)
{
    global translator_radical
    translator_radical := radical
    TranslatorFilterResult()
}

TranslatorToggleSingleMode()
{
    global translator_single_mode
    translator_single_mode := !translator_single_mode
    TranslatorFilterResult()
}

TranslatorGetSendLength(full_input_string, send_pinyin_string)
{
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

TranslatorSendWordThenUpdate()
{
    global tooltip_debug
    global translator_split_indexs
    global translator_input_string
    global translator_select_index

    send_word := TranslatorGetWord(translator_select_index)
    pinyin_string := TranslatorGetPinyin(translator_select_index)

    sent_string_len := TranslatorGetSendLength(translator_input_string, pinyin_string)

    translator_input_string := SubStr(translator_input_string, sent_string_len+1)

    tooltip_debug[11] := "[" send_word "] " pinyin_string "," translator_input_string "," sent_string_len
    TranslatorSetSelectIndex(1)
    TranslatorUpdateInputString(translator_input_string)
    return send_word
}

TranslatorGetLastWordPos()
{
    global translator_split_indexs
    if( translator_split_indexs.Length() <= 1 ){
        return 0
    }
    return translator_split_indexs[translator_split_indexs.Length()-1]
}

TranslatorGetLeftWordPos(start_index)
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

TranslatorGetRightWordPos(start_index)
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

TranslatorGetSelectIndex()
{
    global translator_select_index
    return translator_select_index
}
TranslatorSetSelectIndex(index)
{
    global translator_select_index
    translator_select_index := Max(1, Min(TranslatorGetListLength(), index))
}
TranslatorOffsetSelectIndex(offset)
{
    global translator_select_index
    TranslatorSetSelectIndex(translator_select_index + offset)
}

TranslatorGetListLength()
{
    global translator_candidate_filtered
    return translator_candidate_filtered.Length()
}
TranslatorGetRemainString()
{
    global translator_input_string
    return translator_input_string
}

TranslatorGetDebugInfo(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 0]
}
TranslatorGetPinyin(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 1]
}

TranslatorGetWord(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 2]
}

TranslatorGetWeight(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 3]
}

TranslatorGetComment(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 4]
}

TranslatorGetCommentDisplayText(index)
{
    comment := TranslatorGetComment(index)
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

TranslatorGetIndexWordRadical(index)
{
    global translator_candidate_filtered
    return translator_candidate_filtered[index, 6]
}
TranslatorGetInputRadical()
{
    global translator_radical
    return translator_radical
}

