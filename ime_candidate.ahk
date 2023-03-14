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
        This.candidate := PinyinGetSentences(string)
        This.input_string := string
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
    GetOccupiedPinyin()
    {
        ; TODO: make it work
        return This.GetPinyin(This.select_index)
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

