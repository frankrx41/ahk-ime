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
            This.input_split := PinyinSplit(This.input_string, true)
            This.assistant_code := assistant_code
            This.candidate := PinyinGetSentences(This.input_split, This.input_string, This.assistant_code, DB)
        } else {
            This.input_string := ""
            This.assistant_code := ""
        }
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
        This.Initialize(This.input_string, "", DB)
        return send_word
    }
    GetLeftWordLength(input_split, input_string)
    {
        trim_string := RTrim(input_split, "%'12345")
        prev_word_pos := RegExMatch(trim_string, "[12345'|][^12345'|]*$")
        if( prev_word_pos == 0 ){
            return 0
        } else {
            prev_word := SubStr(trim_string, 1, prev_word_pos-1)
            sent_string_len := This.GetSendLength(input_string, prev_word)
            return sent_string_len
        }
    }
    GetLastWordPos()
    {
        return This.GetLeftWordLength(This.input_split, This.input_string)
    }
    GetLeftWordPos(index)
    {
        left_string := SubStr(This.input_string, 1, index)
        left_string_split := PinyinSplit(left_string, true)
        return This.GetLeftWordLength(left_string_split, left_string)
    }
    GetRightWordLength(input_split, input_string)
    {
        trim_string := RTrim(input_split, "%'12345")
        prev_word := RegExReplace(trim_string, "[12345'|](.*)$")

        sent_string_len := This.GetSendLength(input_string, prev_word)
        return sent_string_len
    }
    GetRightWordPos(index)
    {
        left_index := This.GetLeftWordPos(index+1)
        left_string := SubStr(This.input_string, left_index+1)
        left_string_split := PinyinSplit(left_string, true)
        return This.GetRightWordLength(left_string_split, left_string) + left_index
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

