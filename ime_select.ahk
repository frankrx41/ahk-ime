ImeSelectInitialize()
{
    global ime_select_index
    global ime_selectmenu_column
    global ime_selectmenu_open
    global ime_candidate_sentences

    ime_select_index                := 1        ; 选定的候选词，从 1 开始
    ime_selectmenu_column           := 10       ; 最大候选词个数
    ime_selectmenu_open             := 0        ; 是否打开选字窗口
    ime_candidate_sentences         := [] ; 候选句子
}

;*******************************************************************************
ImeOpenSelectMenu(open)
{
    global ime_selectmenu_open
    global ime_select_index

    ime_selectmenu_open := open
    ime_select_index := 1
    return
}

ImeIsSelectMenuOpen()
{
    global ime_selectmenu_open
    return ime_selectmenu_open
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

    ime_select_index := Max(1, Min(ime_selectmenu_column, ime_candidate_sentences.Length(), index))
}

GetSelectWordIndex()
{
    global ime_select_index
    return ime_select_index
}
