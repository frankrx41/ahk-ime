ImeSelectorInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
    global ime_selector_single_mode         := false
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
    global ime_input_caret_pos
    split_index := ImeTranslatorGetPosSplitIndex(ime_input_caret_pos)
    return ImeTranslatorResultGetSelectIndex(split_index)
}

ImeSelectorResetSelectIndex()
{
    ImeTranslatorResultSetSelectIndex(1,1)
}

ImeSelectorSetSelectIndex(index)
{
    global ime_input_caret_pos
    split_index := ImeTranslatorGetPosSplitIndex(ime_input_caret_pos)
    ImeTranslatorResultSetSelectIndex(split_index, index)
}

ImeSelectorOffsetSelectIndex(offset)
{
    global ime_input_caret_pos
    split_index := ImeTranslatorGetPosSplitIndex(ime_input_caret_pos)
    ImeTranslatorResultSetSelectIndex(split_index, ImeTranslatorResultGetSelectIndex(split_index) + offset)
}

ImeSelectorToggleSingleMode()
{
    global ime_selector_single_mode
    ime_selector_single_mode := !ime_selector_single_mode
    ImeTranslatorFilterResults(ime_selector_single_mode)
}

; "woaini" => ["我爱你", "", ""]
; if first word select "卧", then update to ["卧", "爱你", ""]
; if last word select "泥", then update to ["我爱", "", "泥"]
ImeSelectorFixupSelectIndex()
{
    ImeTranslatorFixupSelectIndex()
}
