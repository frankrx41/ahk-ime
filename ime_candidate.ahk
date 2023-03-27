class Candidate
{
    __New() {
        This.select_index   := 1    ; 选定的候选词，从 1 开始
        This.input_string   := ""
        This.input_split    := ""
        This.split_indexs   := []
        This.radical        := ""
    }

    Initialize(input_string, DB:="") {
        ; [
        ;     ; -1 , 0         , 1
        ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
        ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
        ;     ...
        ; ]
        local
        input_string := LTrim(input_string, " ")
        if( input_string )
        {
            This.input_string := input_string
            split_indexs := []
            This.input_split := PinyinSplit(This.input_string, split_indexs)
            This.split_indexs := split_indexs
            This.candidate_origin := PinyinGetSentences(This.input_string, This.input_split, DB)
            This.candidate_filtered := CopyObj(This.candidate_origin)
        } else {
            This.input_string := ""
        }
    }

    UpdateInputRadical(radical)
    {
        local
        This.radical := radical
        search_result := This.candidate_origin
        if( This.radical ){
            PinyinResultFilterByRadical(search_result, This.radical)
        }
        This.candidate_filtered := search_result
    }

    GetSendLength(full_input_string, send_pinyin_string)
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

    SendWordThenUpdate(DB)
    {
        global tooltip_debug

        send_word := This.GetWord(This.select_index)
        pinyin_string := This.GetPinyin(This.select_index)

        sent_string_len := This.GetSendLength(This.input_string, pinyin_string)

        This.input_string := SubStr(This.input_string, sent_string_len+1)

        tooltip_debug[11] := "[" send_word "] " pinyin_string "," This.input_string "," sent_string_len
        This.SetSelectIndex(1)
        This.Initialize(This.input_string, DB)
        return send_word
    }

    GetLastWordPos()
    {
        if( This.split_indexs.Length() <= 1 ){
            return 0
        }
        return This.split_indexs[This.split_indexs.Length()-1]
    }
    GetLeftWordPos(start_index)
    {
        local
        if( start_index == 0 ){
            return This.split_indexs[This.split_indexs.Length()]
        }
        last_index := 0
        loop, % This.split_indexs.Length()
        {
            split_index := This.split_indexs[A_Index]
            if( split_index >= start_index ){
                break
            }
            last_index := split_index
        }
        return last_index
    }
    GetRightWordPos(start_index)
    {
        local
        last_index := 0
        loop, % This.split_indexs.Length()
        {
            split_index := This.split_indexs[A_Index]
            if( split_index > start_index ){
                last_index := split_index
                break
            }
        }
        return last_index
    }

    GetSelectIndex()
    {
        return This.select_index
    }
    SetSelectIndex(index)
    {
        This.select_index := Max(1, Min(This.GetListLength(), index))
    }
    OffsetSelectIndex(offset)
    {
        This.SetSelectIndex(This.select_index + offset)
    }

    GetListLength()
    {
        return This.candidate_filtered.Length()
    }
    GetRemainString()
    {
        return This.input_string
    }

    GetDebugInfo(index)
    {
        return This.candidate_filtered[index, 0]
    }
    GetPinyin(index)
    {
        return This.candidate_filtered[index, 1]
    }

    GetWord(index)
    {
        return This.candidate_filtered[index, 2]
    }

    GetWeight(index)
    {
        return This.candidate_filtered[index, 3]
    }

    GetComment(index)
    {
        return This.candidate_filtered[index, 4]
    }

    GetCommentDisplayText(index)
    {
        comment := This.GetComment(index)
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

    GetIndexWordRadical(index)
    {
        return This.candidate_filtered[index, 6]
    }
    GetInputRadical()
    {
        return This.radical
    }
}

