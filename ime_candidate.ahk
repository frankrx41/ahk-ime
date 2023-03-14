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
        occupied_str := This.GetPinyin(This.select_index)

        sent_string := This.GetWord()
        This.input_string := SubStr(This.input_string, StrLen(occupied_str)+1-StrLen(sent_string)+1)

        tooltip_debug[11] := sent_string "," occupied_str "," This.input_string
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

