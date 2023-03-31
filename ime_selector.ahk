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
    split_index := ImeInputterGetCaretSplitIndex()
    return ImeSelectorGetSelectIndex(split_index)
}

ImeSelectorSetCaretSelectIndex(select_index)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), select_index))
    ImeSelectorSetSelectIndex(split_index, select_index)
}

ImeSelectorOffsetCaretSelectIndex(offset)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index) + offset
    select_index := Max(1, Min(ImeTranslatorResultGetListLength(split_index), select_index))
    ImeSelectorSetSelectIndex(split_index, select_index)
}

;*******************************************************************************
;
ImeSelectorToggleSingleMode()
{
    Assert(false, "not implement!", true)
    ; global ime_selector_single_mode
    ; ime_selector_single_mode := !ime_selector_single_mode
    ; ImeTranslatorFilterResults(ime_selector_single_mode)
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
    word_length := ImeTranslatorResultGetLength(split_index, select_index)

    if( lock_result )
    {
        ; Find if prev has a reuslt length include this
        ; e.g. lock "我爱你", then can not change "爱你"
        test_length := 0
        loop
        {
            if( A_Index >= split_index ){
                break
            }
            if( ImeSelectorIsSelectLock(A_Index) )
            {
                if( test_length + ImeSelectorGetLockLength(A_Index) >= split_index ){
                    ImeSelectorUnLockWord(A_Index)
                    break
                }
            }
            else {
                test_length += 1
            }
        }
        ; Lock this
        select_word := ImeTranslatorResultGetWord(split_index, select_index)
        word_length := ImeTranslatorResultGetLength(split_index, select_index)
        ImeSelectorLockWord(split_index, select_word, word_length)
    }

    ImeTranslatorFixupSelectIndex()

    if( !ImeInputterCaretIsAtEnd() )
    {
        ImeInputterCaretMoveByWord(word_length)
    }

    debug_info .= "[" split_index "]->[" lock_result "]"
    ImeProfilerEnd(41, debug_info)
}

;*******************************************************************************
; [split_index, 0] = select info
;   - 1: select index, work for selector menu, 0 mark not select, should skip this
;   - 2: is lock
;   - lock use:
;       - 3: word value
;       - 4: length
ImeSelectorUnLockWord(split_index)
{
    global ime_selector_select
    ime_selector_select[split_index, 2] := false
    ime_selector_select[split_index, 3] := ""
    ime_selector_select[split_index, 4] := 0
}

ImeSelectorLockWord(split_index, select_word, word_length)
{
    local
    global ime_selector_select
    ime_selector_select[split_index, 2] := true
    ime_selector_select[split_index, 3] := select_word
    ime_selector_select[split_index, 4] := word_length
    ImeProfilerBegin(43, true)
    debug_info := "`n  - [" split_index "]->[" select_word "," word_length "] "
    ImeProfilerEnd(43, debug_info)
}

ImeSelectorSetSelectIndex(split_index, select_index)
{
    local
    global ime_selector_select

    ime_selector_select[split_index, 1] := select_index

    ImeProfilerBegin(42, true)
    debug_info := "`n  - [" split_index "]->[" select_index "] " RegExReplace(CallStack(1), "^.*\\")
    ImeProfilerEnd(42, debug_info)
}

ImeSelectorGetSelectIndex(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 1] ? ime_selector_select[split_index, 1] : 0
}

ImeSelectorIsSelectLock(split_index)
{
    local
    global ime_selector_select
    ImeProfilerBegin(44, true)
    debug_info := "`n  - [" split_index "]->[" ime_selector_select[split_index, 2] "] " RegExReplace(CallStack(1), "^.*\\")
    ImeProfilerEnd(44, debug_info)
    return ime_selector_select[split_index, 2] ? true : false
}

ImeSelectorGetLockWord(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 3]
}

ImeSelectorGetLockLength(split_index)
{
    global ime_selector_select
    return ime_selector_select[split_index, 4]
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
