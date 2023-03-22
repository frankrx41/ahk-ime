class Candidate
{
    __New() {
        This.select_index   := 1    ; 选定的候选词，从 1 开始
        This.candidate      := []
        This.input_string   := ""
        This.input_split    := ""
    }

    Initialize(input_string, assistant_code:="", DB:="") {
        ; [
        ;     ; -1 , 0         , 1
        ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
        ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
        ;     ...
        ; ]
        input_string := LTrim(input_string, " ")
        if( input_string )
        {
            This.input_string := input_string
            This.input_split := PinyinSplit(This.input_string, true, DB)
            This.assistant_code := assistant_code
            This.candidate := PinyinGetSentences(This.input_split, This.input_string, This.assistant_code, DB)
        } else {
            This.input_string := ""
            This.assistant_code := ""
        }
    }

    SendWordThenUpdate(DB)
    {
        global tooltip_debug

        send_word := This.GetWord(This.select_index)
        pinyin_string := This.GetPinyin(This.select_index)

        index_pinyin    := 1
        index_input     := 1
        sent_string_len := 0
        sent_pinyin_len := StrLen(pinyin_string)
        ; "wohenxihuanni" - "wo'hen" = "xihuanni"
        loop, Parse, % This.input_string
        {
            match := false
            if( index_pinyin > sent_pinyin_len ){
                break
            }
            loop
            {
                input_char := SubStr(This.input_string, index_input, 1)
                if( input_char == " " ){
                    index_input += 1
                    sent_string_len += 1
                } else {
                    break
                }
            }
            loop
            {
                pinyin_char := SubStr(pinyin_string, index_pinyin, 1)
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

        This.input_string := SubStr(This.input_string, sent_string_len+1)

        tooltip_debug[11] := "[" send_word "] " pinyin_string "," This.input_string "," sent_string_len
        This.SetSelectIndex(1)
        This.Initialize(This.input_string, "", DB)
        return send_word
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
        return This.candidate.Length()
    }
    GetRemainString()
    {
        return This.input_string
    }

    GetDebugInfo(index)
    {
        return This.candidate[index, 0]
    }
    GetPinyin(index)
    {
        return This.candidate[index, 1]
    }

    GetWord(index)
    {
        return This.candidate[index, 2]
    }

    GetWeight(index)
    {
        return This.candidate[index, 3]
    }

    GetComment(index)
    {
        return This.candidate[index, 4]
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

    GetAssistant(index)
    {
        return This.candidate[index, 6]
    }
}

