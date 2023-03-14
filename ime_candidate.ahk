class Candidate
{
    __New() {
        This.select_index   := 1    ; 选定的候选词，从 1 开始
        This.candidate      := []
        This.input_string   := ""
    }

    Initialize(string) {
        ; [
        ;     ; -1 , 0         , 1
        ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
        ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
        ;     ...
        ; ]
        string := LTrim(string, " ")
        if( string )
        {
            This.candidate := PinyinGetSentences(string)
            This.input_string := string
        }
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
        global tooltip_debug
        ; TODO: make it work
        sent_string := This.GetWord(This.select_index)
        pinyin_string := This.GetPinyin(This.select_index)

        index_pinyin    := 1
        index_input     := 1
        sent_string_len := 1
        sent_pinyin_len := StrLen(pinyin_string)
        ; "wohenxihuanni" - "wo'hen"
        loop, Parse, % This.input_string
        {
            if( index_pinyin >= sent_pinyin_len ){
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
                if( pinyin_char == input_char ) {
                    break
                }
                index_pinyin += 1
            }
            sent_string_len += 1
            index_pinyin    += 1
            index_input     += 1
        }

        This.input_string := SubStr(This.input_string, sent_string_len+1)

        tooltip_debug[11] := "[" sent_string "] " pinyin_string "," This.input_string "," sent_string_len
        This.SetSelectIndex(1)
        This.Initialize(This.input_string)
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
}

