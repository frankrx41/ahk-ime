ImeSelectorInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
    global ime_selector_single_mode         := false
    global ime_selector_select              := []
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

;*******************************************************************************
;
ImeSelectorGetCaretSelectIndex()
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    return ImeSelectorGetSelectIndex(split_index)
}

ImeSelectorSetCaretSelectIndex(index)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), index))
    ImeSelectorSetSelectIndex(split_index, index, false)
}

ImeSelectorOffsetCaretSelectIndex(offset)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    index := ImeSelectorGetSelectIndex(split_index) + offset
    index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), index))
    ImeSelectorSetSelectIndex(split_index, index, false)
}

;*******************************************************************************
;
ImeSelectorToggleSingleMode()
{
    global ime_selector_single_mode
    ime_selector_single_mode := !ime_selector_single_mode
    ImeTranslatorFilterResults(ime_selector_single_mode)
}

;*******************************************************************************
; "woaini" => ["我爱你", "", ""]
; if first word select "卧", then update to ["卧", "爱你", ""]
; if last word select "泥", then update to ["我爱", "", "泥"]
ImeSelectorFixupSelectIndex(lock_result)
{
    local
    ImeProfilerBegin(41, true)
    debug_info := ""

    if( lock_result )
    {
        split_index := ImeInputterGetCaretSplitIndex()
        select_index := ImeSelectorGetSelectIndex(split_index)
        lock_word := ImeTranslatorResultGetWord(split_index, select_index)
        lock_word_length := ImeTranslatorResultGetLength(split_index, select_index)
        ImeTranslatorFixupSelectIndex(split_index, lock_word, lock_word_length)
        debug_info .= "Lock: [" split_index "," select_index "]:""" lock_word """"
    }
    else
    {
        ImeTranslatorFixupSelectIndex()
    }
    if( !ImeInputterCaretIsAtEnd() )
    {
        split_index := ImeInputterGetCaretSplitIndex()
        select_index := ImeSelectorGetSelectIndex(split_index)
        word_length := ImeTranslatorResultGetLength(split_index, select_index)
        ImeInputterCaretMoveByWord(word_length)
    }
    ImeProfilerEnd(41, debug_info)
}

;*******************************************************************************
; [split_index, 0] = select info
;   - 1: select index, work for selector menu, 0 mark not select, should skip this
;   - 2: is lock
;   - 3: value
;   - 4: length
ImeSelectorSetSelectIndex(split_index, word_index, lock_select:=true, select_word:="", word_length:=0)
{
    local
    global ime_selector_select
    if( word_index != 0 )
    {
        if( select_word == "" ) {
            select_word := ImeTranslatorResultGetWord(split_index, word_index)
        }
        if( word_length == 0 ) {
            word_length := ImeTranslatorResultGetLength(split_index, word_index)
        }
    }
    ime_selector_select[split_index] := [word_index, lock_select, select_word, word_length]
}

ImeSelectorGetSelectIndex(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 1]
}

ImeSelectorIsSelectLock(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 0, 2]
}

ImeSelectorGetSelectWord(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 0, 3]
}

ImeSelectorGetSelectLength(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 0, 4]
}


;*******************************************************************************
;
ImeSelectorGetOutputString()
{
    global ime_selector_select

    result_string := ""
    loop % ime_selector_select.Length()
    {
        split_index := A_Index
        select_index := ImeSelectorGetSelectIndex(split_index)
        if( select_index > 0 )
        {
            result_string .= ImeTranslatorResultGetWord(split_index, select_index)
        }
    }
    return result_string
}