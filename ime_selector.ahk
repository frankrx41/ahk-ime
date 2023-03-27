ImeSelectorInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
}

;*******************************************************************************
ImeSelectorOpen(open, more := false)
{
    global ime_selector_is_open
    global ime_selector_is_show_multiple

    ime_selector_is_open := open
    ime_selector_is_show_multiple := more
    return
}

ImeSelectorIsOpen()
{
    global ime_selector_is_open
    return ime_selector_is_open
}

ImeSelectorShowMultiple()
{
    global ime_selector_is_show_multiple
    return ime_selector_is_show_multiple
}

ImeSelectorGetColumn()
{
    global ime_selector_column
    return ime_selector_column
}

ImeSelectorGetSelectIndex()
{
    global ime_input_candidate
    return ime_input_candidate.GetSelectIndex()
}

ImeSelectorSetSelectIndex(index)
{
    global ime_input_candidate
    ime_input_candidate.SetSelectIndex(index)
}

ImeSelectorOffsetSelectIndex(offset)
{
    global ime_input_candidate
    ime_input_candidate.OffsetSelectIndex(offset)
}
