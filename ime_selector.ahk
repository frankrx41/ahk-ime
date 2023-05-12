ImeSelectorInitialize()
{
    global ime_selector_select_list
    global ime_selector_store_select_index
}

ImeSelectorClear()
{
    global ime_selector_select_list
    global ime_selector_store_select_index
    ime_selector_select_list := []
    ime_selector_store_select_index := 0
}

;*******************************************************************************
;
ImeSelectorGetCaretSelectIndex()
{
    local
    global ime_selector_select_list
    split_index := ImeInputterGetCaretSplitIndex()
    return SelectorResultGetSelectIndex(ime_selector_select_list[split_index])
}

ImeSelectorStoreSelectIndexBeforeMenuOpen()
{
    global ime_selector_store_select_index
    ime_selector_store_select_index := ImeSelectorGetCaretSelectIndex()
}

ImeSelectorCancelCaretSelectIndex()
{
    global ime_selector_select_list
    global ime_selector_store_select_index
    split_index := ImeInputterGetCaretSplitIndex()
    SelectorResultSetSelectIndex(ime_selector_select_list[split_index], ime_selector_store_select_index)
}

ImeSelectorSetCaretSelectIndex(select_index)
{
    local
    global ime_selector_select_list
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := Max(1, Min(CandidateGetListLength(ImeCandidateGet(), split_index), select_index))
    if( !ime_selector_select_list[split_index] ){
        ime_selector_select_list[split_index] := []
    }
    SelectorResultSetSelectIndex(ime_selector_select_list[split_index], select_index)
}

ImeSelectorOffsetCaretSelectIndex(offset)
{
    local
    global ime_selector_select_list
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index) + offset
    select_index := Max(1, Min(CandidateGetListLength(ImeCandidateGet(), split_index), select_index))
    SelectorResultSetSelectIndex(ime_selector_select_list[split_index], select_index)
}

;*******************************************************************************
;
ImeSelectorToggleSingleMode()
{
    ; TODO:
    ; Assert(false, "not implement!", true)
    ; global ime_selector_single_mode
    ; ime_selector_single_mode := !ime_selector_single_mode
    ; CandidateResultListFilterResults(ime_selector_single_mode)
}

;*******************************************************************************
; "woaini" => ["我爱你", "", ""]
; if first word select "卧", then update to ["卧", "爱你", ""]
; if last word select "泥", then update to ["我爱", "", "泥"]
ImeSelectorApplyCaretSelectIndex(lock_result)
{
    local
    global ime_selector_select_list
    ImeProfilerBegin(41)
    profile_text := ""

    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index)
    word_length := CandidateGetWordLength(ImeCandidateGet(), split_index, select_index)

    if( lock_result )
    {
        SelectorResultUnLockFrontWords(ime_selector_select_list, split_index)
        ; Lock this
        select_word := CandidateGetWord(ImeCandidateGet(), split_index, select_index)
        word_length := CandidateGetWordLength(ImeCandidateGet(), split_index, select_index)
        SelectorResultLockWord(ime_selector_select_list[split_index], select_word, word_length)
        loop, % word_length-1
        {
            test_index := split_index + A_Index
            if( ImeSelectorIsSelectLock(test_index) ){
                SelectorResultUnLockWord(ime_selector_select_list[test_index])
            }
        }
    }

    ime_selector_select_list := SelectorFixupSelectIndex(ImeCandidateGet(), ime_selector_select_list)

    if( !ImeInputterCaretIsAtEnd() )
    {
        ImeInputterCaretMoveByWord(word_length, false)
    }

    profile_text .= "[" split_index "]->[" select_index "," word_length "," lock_result "]"
    ImeProfilerEnd(41, profile_text)
}

ImeSelectorUnlockWords(split_index, unlock_front)
{
    global ime_selector_select_list
    if( unlock_front ) {
        SelectorResultUnLockFrontWords(ime_selector_select_list, split_index)
    } else {
        SelectorResultUnLockAfterWords(ime_selector_select_list, split_index)
    }
}

;*******************************************************************************
;
ImeSelectorSetSelectIndex(split_index, select_index)
{
    global ime_selector_select_list
    if( !ime_selector_select_list[split_index] ){
        ime_selector_select_list[split_index] := []
    }
    return SelectorResultSetSelectIndex(ime_selector_select_list[split_index], select_index)
}

ImeSelectorGetSelectIndex(split_index)
{
    global ime_selector_select_list
    return SelectorResultGetSelectIndex(ime_selector_select_list[split_index])
}

ImeSelectorIsSelectLock(split_index)
{
    global ime_selector_select_list
    return SelectorResultIsSelectLock(ime_selector_select_list[split_index])
}

ImeSelectorGetLockWord(split_index)
{
    global ime_selector_select_list
    return SelectorResultGetLockWord(ime_selector_select_list[split_index])
}

ImeSelectorGetLockLength(split_index)
{
    global ime_selector_select_list
    return SelectorResultGetLockLength(ime_selector_select_list[split_index])
}

;*******************************************************************************
;
ImeSelectorGetOutputString(as_legacy := false)
{
    global ime_selector_select_list

    result_string := ""
    if( as_legacy )
    {
        result_string := ImeInputterGetLegacyOutputString()
    }
    else
    {
        loop % ime_selector_select_list.Length()
        {
            split_index := A_Index
            select_index := ImeSelectorGetSelectIndex(split_index)
            if( select_index > 0 )
            {
                result_string .= CandidateGetWord(ImeCandidateGet(), split_index, select_index)
            }
        }
    }
    return result_string
}
