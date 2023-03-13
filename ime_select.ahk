ImeSelectInitialize()
{
    global ime_select_index         := 1        ; 选定的候选词，从 1 开始
    global ime_selectmenu_column    := 10       ; 最大候选词个数
    global ime_selectmenu_open      := 0        ; 是否打开选字窗口
    global ime_selectmenu_more      := 0        ; Show more column
    ;TODO: hide below variable only in this file
    global ime_candidate_sentences  := []       ; 候选句子
}

;*******************************************************************************
ImeOpenSelectMenu(open, more := false)
{
    global ime_selectmenu_open
    global ime_selectmenu_more

    ime_selectmenu_open := open
    ime_selectmenu_more := more
    return
}

ImeIsSelectMenuOpen()
{
    global ime_selectmenu_open
    return ime_selectmenu_open
}

ImeIsSelectMenuMore()
{
    global ime_selectmenu_more
    return ime_selectmenu_more
}

OffsetSelectWordIndex(offset)
{
    global ime_select_index
    SetSelectWordIndex(ime_select_index + offset)
}

SetSelectWordIndex(index)
{
    global ime_select_index
    global ime_candidate_sentences
    global ime_selectmenu_column

    ime_select_index := Max(1, Min(ime_candidate_sentences.Length(), index))
}

GetSelectWordIndex()
{
    global ime_select_index
    return ime_select_index
}

GetSelectMenuColumn()
{
    global ime_selectmenu_column
    return ime_selectmenu_column
}

;*******************************************************************************
;
ImeUpdateCandidate(string)
{
    global tooltip_debug
    global ime_candidate_sentences
    static last_string := ""
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    if( last_string != string ){
        last_string := string
        ime_candidate_sentences := PinyinGetSentences(string)
        tooltip_debug[1] := "Update candidate: " string
    } else {
        tooltip_debug[1] := "Use old candidate: " string
    }
}

ImeGetCandidateDebugInfo(index)
{
    global ime_candidate_sentences
    return ime_candidate_sentences[index, 0]
}

ImeGetCandidatePinyin(index)
{
    global ime_candidate_sentences
    return ime_candidate_sentences[index, 1]
}

ImeGetCandidateWord(index)
{
    global ime_candidate_sentences
    return ime_candidate_sentences[index, 2]
}

ImeGetCandidateWeight(index)
{
    global ime_candidate_sentences
    return ime_candidate_sentences[index, 3]
}

ImeGetCandidateListLength()
{
    global ime_candidate_sentences
    return ime_candidate_sentences.Length()
}