ImeSelectInitialize()
{
    global ime_select_index         := 1        ; 选定的候选词，从 1 开始
    global ime_selectmenu_column    := 10       ; 最大候选词个数
    global ime_selectmenu_open      := 0        ; 是否打开选字窗口
    global ime_selectmenu_more      := 0        ; Show more column
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
    global ime_input_candidate
    global ime_selectmenu_column

    ime_select_index := Max(1, Min(ime_input_candidate.Length(), index))
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
ImeGetCandidate(string)
{
    global tooltip_debug
    return PinyinGetSentences(string)
}

ImeGetCandidateDebugInfo(candidate, index)
{
    return candidate[index, 0]
}

ImeGetCandidatePinyin(candidate, index)
{
    return candidate[index, 1]
}

ImeGetCandidateWord(candidate, index)
{
    return candidate[index, 2]
}

ImeGetCandidateWeight(candidate, index)
{
    return candidate[index, 3]
}
