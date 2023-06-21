ImeSelectorInitialize()
{
    global ime_selector_select_list     ; See lib_selector_result.ahk

    ImeSelectorSingleModeInitialize()
    ImeSelectorStoreSelectInitialize()
}

ImeSelectorClear()
{
    global ime_selector_select_list
    ime_selector_select_list := []

    ImeSelectorSingleModeClear()
    ImeSelectorStoreSelectClear()
}

;*******************************************************************************
;
ImeSelectorGetAvailableSelect(new_select, split_index)
{
    global ime_selector_select_list
    return SelectorGetAvailableSelect(ime_selector_select_list, ImeCandidateGet(), new_select, split_index)
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

ImeSelectorSetCaretSelectIndex(select_index)
{
    local
    global ime_selector_select_list
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetAvailableSelect(select_index, split_index)
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
    if( select_index == 0 && ImeCandidateGetTranslatorListLength(split_index) < 10 ) {
        select_index := ImeCandidateGetTranslatorListLength(split_index)
    }
    else
    if( select_index == ImeCandidateGetTranslatorListLength(split_index) + 1 && select_index < 11 ) {
        select_index := 1
    }
    else {
        select_index := ImeSelectorGetAvailableSelect(select_index, split_index)
    }
    SelectorResultSetSelectIndex(ime_selector_select_list[split_index], select_index)
}

ImeSelectorFixupSelectIndex(candidate)
{
    global ime_selector_select_list
    ime_selector_select_list := SelectorFixupSelectIndex(candidate, ime_selector_select_list)
}

;*******************************************************************************
; "woaini" => ["我爱你", "", ""]
; if first word select "卧", then update to ["卧", "爱你", ""]
; if last word select "泥", then update to ["我爱", "", "泥"]
ImeSelectorApplyCaretSelectIndex(lock_result, move_caret:=true)
{
    local

    Assert(lock_result == true, "", false)

    if( !ImeInputterCaretSplitIndexIsEnd() ) {
        ImeSelectorApplyCaretSelectIndexNormal(move_caret)
    } else {
        ImeSelectorApplyCaretSelectIndexLast()
    }
}

ImeSelectorApplyCaretSelectIndexNormal(move_caret)
{
    global ime_selector_select_list

    ImeProfilerBegin()
    profile_text := ""

    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index)
    word_length := ImeCandidateGetWordLength(split_index, select_index)

    if( true )
    {
        SelectorResultUnLockFrontWords(ime_selector_select_list, split_index)
        ; Lock this
        select_word := ImeCandidateGetWord(split_index, select_index)
        word_length := ImeCandidateGetWordLength(split_index, select_index)
        SelectorResultLockWord(ime_selector_select_list[split_index], select_word, word_length)
        loop, % word_length-1
        {
            test_index := split_index + A_Index
            if( ImeSelectorIsSelectLock(test_index) ){
                SelectorResultUnLockWord(ime_selector_select_list[test_index])
            }
        }
        ImeSelectorFixupSelectIndex(ImeCandidateGet())
    }

    if( move_caret && !ImeInputterCaretIsAtEnd() )
    {
        ImeInputterCaretMoveByWord(word_length, false)
    }

    profile_text .= "[" split_index "]->[" select_index "," word_length "]"
    ImeProfilerEnd(profile_text)
}

ImeSelectorApplyCaretSelectIndexLast()
{
    global ime_selector_select_list

    ImeProfilerBegin()
    split_index := ImeInputterGetCaretSplitIndex()
    select_index := ImeSelectorGetSelectIndex(split_index)

    SelectorResultSetSelectIndex(ime_selector_select_list[split_index],select_index)
    ImeSelectorFixupSelectIndex(ImeCandidateGet())

    profile_text := "[" split_index "]->[" select_index "]"
    ImeProfilerEnd(profile_text)
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
        result_string := ImeInputterStringGetLegacy()
    }
    else
    {
        loop % ime_selector_select_list.Length()
        {
            split_index := A_Index
            select_index := ImeSelectorGetSelectIndex(split_index)
            if( select_index > 0 )
            {
                select_word := ImeCandidateGetWord(split_index, select_index)
                result_string .= select_word
                if( select_word && !ImeCandidateIsTraditional(split_index, select_index) )
                {
                    input_pinyin := ImeCandidateGetLegacyPinyin(split_index, select_index)
                    ImeTranslatorDynamicMark(input_pinyin, select_word)
                }
            }
        }
    }
    return result_string
}
