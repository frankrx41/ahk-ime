ImeSelectorInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
    global ime_selector_single_mode         := false
}

;*******************************************************************************
;
ImeSelectorOpen(multiple:=false)
{
    local
    global ime_selector_is_open
    global ime_selector_is_show_multiple

    ime_selector_is_open := true
    if( ImeInputterIsInputDirty() )
    {
        ImeInputterUpdateString("")
    }

    if( multiple ){
        multiple := ImeSelectorCanShowMultiple()
    }
    ime_selector_is_show_multiple := multiple
}

ImeSelectorClose(lock_result:=true)
{
    global ime_selector_is_open
    ime_selector_is_open := false
    ImeSelectorFixupSelectIndex(lock_result)
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

ImeSelectorCanShowMultiple()
{
    split_index := ImeInputterGetCaretSplitIndex()
    return ImeTranslatorResultGetListLength(split_index) > ImeSelectorGetColumn()
}

ImeSelectorGetColumn()
{
    global ime_selector_column
    return ime_selector_column
}

ImeSelectorGetSelectIndex()
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    return ImeTranslatorResultGetSelectIndex(split_index)
}

ImeSelectorSetSelectIndex(index)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), index))
    ImeTranslatorResultSetSelectIndex(split_index, index)
}

ImeSelectorOffsetSelectIndex(offset)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
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
ImeSelectorFixupSelectIndex(lock_result)
{
    local
    ImeProfilerBegin(41)
    ImeTranslatorFixupSelectIndex()
    if( !ImeInputterCaretIsAtEnd() )
    {
        split_index := ImeInputterGetCaretSplitIndex()
        select_index := ImeTranslatorResultGetSelectIndex(split_index)
        word_length := ImeTranslatorResultGetLength(split_index, select_index)
        ImeInputterCaretMoveByWord(word_length)
    }
    ImeProfilerEnd(41)
}
