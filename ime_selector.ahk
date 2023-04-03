ImeSelectorInitialize()
{
    global ime_selector_select
}

ImeSelectorClear()
{
    global ime_selector_select
    ime_selector_select := []
}

;*******************************************************************************
;
ImeSelectorGetCaretSelectIndex()
{
    local
    global ime_selector_select
    split_index := ImeInputterGetCaretSplitIndex()
    return SelectorResultGetSelectIndex(ime_selector_select, split_index)
}

ImeSelectorCancelCaretSelectIndex()
{
    global ime_selector_select
    split_index := ImeInputterGetCaretSplitIndex()
    SelectorResultSetSelectIndex(ime_selector_select, split_index, 0)
}

ImeSelectorSetCaretSelectIndex(select_index)
{
    local
    global ime_selector_select
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := Max(1, Min(ImeTranslatorResultListGetListLength(split_index), select_index))
    SelectorResultSetSelectIndex(ime_selector_select, split_index, select_index)
}

ImeSelectorOffsetCaretSelectIndex(offset)
{
    local
    global ime_selector_select
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index) + offset
    select_index := Max(1, Min(ImeTranslatorResultListGetListLength(split_index), select_index))
    SelectorResultSetSelectIndex(ime_selector_select, split_index, select_index)
}

;*******************************************************************************
;
ImeSelectorToggleSingleMode()
{
    Assert(false, "not implement!", true)
    ; global ime_selector_single_mode
    ; ime_selector_single_mode := !ime_selector_single_mode
    ; TranslatorResultListFilterResults(ime_selector_single_mode)
}

;*******************************************************************************
; "woaini" => ["我爱你", "", ""]
; if first word select "卧", then update to ["卧", "爱你", ""]
; if last word select "泥", then update to ["我爱", "", "泥"]
ImeSelectorApplyCaretSelectIndex(lock_result)
{
    local
    global ime_selector_select
    ImeProfilerBegin(41, true)
    debug_info := ""

    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index)
    word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)

    if( lock_result )
    {
        SelectorResultUnLockFrontWords(ime_selector_select, split_index)
        ; Lock this
        select_word := ImeTranslatorResultListGetWord(split_index, select_index)
        word_length := ImeTranslatorResultListGetWordLength(split_index, select_index)
        SelectorResultLockWord(ime_selector_select, split_index, select_word, word_length)
        loop, % word_length-1
        {
            test_index := split_index + A_Index
            if( ImeSelectorIsSelectLock(test_index) ){
                SelectorResultUnLockWord(ime_selector_select, test_index)
            }
        }
    }

    SelectorResultUnLockWord(ime_selector_select, split_index)
    ImeSelectorFixupSelectIndex()

    if( !ImeInputterCaretIsAtEnd() )
    {
        ImeInputterCaretMoveByWord(word_length)
    }

    debug_info .= "[" split_index "]->[" lock_result "]"
    ImeProfilerEnd(41, debug_info)
}

ImeSelectorUnlockWords(split_index, unlock_front)
{
    global ime_selector_select
    if( unlock_front ) {
        SelectorResultUnLockFrontWords(ime_selector_select, split_index)
    } else {
        SelectorResultUnLockAfterWords(ime_selector_select, split_index)
    }
}

;*******************************************************************************
; [split_index, 0] = select info
;   - 1: select index, work for selector menu, 0 mark not select, should skip this
;   - 2: is lock
;   - lock use:
;       - 3: word value
;       - 4: length

ImeSelectorSetSelectIndex(split_index, select_index)
{
    global ime_selector_select
    return SelectorResultSetSelectIndex(ime_selector_select, split_index, select_index)
}

ImeSelectorGetSelectIndex(split_index)
{
    global ime_selector_select
    return SelectorResultGetSelectIndex(ime_selector_select, split_index)
}

ImeSelectorIsSelectLock(split_index)
{
    global ime_selector_select
    return SelectorResultIsSelectLock(ime_selector_select, split_index)
}

ImeSelectorGetLockWord(split_index)
{
    global ime_selector_select
    return SelectorResultGetLockWord(ime_selector_select, split_index)
}

ImeSelectorGetLockLength(split_index)
{
    global ime_selector_select
    return SelectorResultGetLockLength(ime_selector_select, split_index)
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
            result_string .= ImeTranslatorResultListGetWord(split_index, select_index)
        }
    }
    return result_string
}
