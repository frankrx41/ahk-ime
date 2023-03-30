ImeSelectorInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
    global ime_selector_single_mode         := false
}

;*******************************************************************************
;
ImeSelectorOpen(open, more := false)
{
    local
    global ime_selector_is_open
    global ime_selector_is_show_multiple
    global ime_input_caret_pos
    global ime_input_string

    ime_selector_is_open := open
    if( open )
    {
        ImeInputterUpdateString(ime_input_string)
    }
    if( more ){
        split_index := ImeInputterGetPosSplitIndex()
        more := ImeTranslatorResultGetListLength(split_index) > ImeSelectorGetColumn()
    }
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
    local
    split_index := ImeInputterGetPosSplitIndex()
    return ImeTranslatorResultGetSelectIndex(split_index)
}

ImeSelectorResetSelectIndex()
{
    ImeTranslatorResultSetSelectIndex(1,1)
}

ImeSelectorSetSelectIndex(index)
{
    local
    split_index := ImeInputterGetPosSplitIndex()
    index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), index))
    ImeTranslatorResultSetSelectIndex(split_index, index)
}

ImeSelectorOffsetSelectIndex(offset)
{
    local
    split_index := ImeInputterGetPosSplitIndex()
    index := ImeTranslatorResultGetSelectIndex(split_index) + offset
    index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), index))
    ImeTranslatorResultSetSelectIndex(split_index, index)
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
    local
    global ime_input_caret_pos
    global ime_input_string
    ImeTranslatorFixupSelectIndex()
    if( ime_input_caret_pos != StrLen(ime_input_string) )
    {
        split_index := ImeInputterGetPosSplitIndex()
        select_index := ImeTranslatorResultGetSelectIndex(split_index)
        word_length := ImeTranslatorResultGetLength(split_index, select_index)
        ImeInputterCaretMoveByWord(word_length)
    }
}
