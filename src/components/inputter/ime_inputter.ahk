;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    ImeInputterClearAll()
    ImeInputterHistoryClear()
}

;*******************************************************************************
; Enter port
ImeInputterClearAll()
{
    global ime_input_string
    global ime_input_is_dirty
    global ime_splitted_list
    global ime_input_caret_pos

    ime_input_string    := ""
    ime_input_is_dirty  := true
    ime_splitted_list   := []
    ime_input_caret_pos := 0

    ImeSelectorClear()
    ImeCandidateClear()
    ImeProfilerTickClear()
    return
}

;*******************************************************************************
; Update result
ImeInputterUpdateString(input_char)
{
    local
    global ime_input_string
    global ime_splitted_list
    global ime_input_is_dirty

    ime_input_is_dirty := true
    ImeProfilerClear()

    if( ime_input_string )
    {
        ImeProfilerTickBegin()
        ; Splitter
        ime_splitted_list := ImeSplitterInputString(ime_input_string)
        ; Translator
        ImeInputterCallTranslator()
    
        ImeProfilerTickEnd()
    }
    else
    {
        ImeInputterClearAll()
    }

    ime_input_is_dirty := false
}

ImeInputterCallTranslator()
{
    global ime_splitted_list

    ImeProfilerBegin()
    profile_text := ""

    caret_splitted_index := ImeInputterGetCaretSplitIndex()

    splitter_result_list := CopyObj(ime_splitted_list)
    profile_text .= "[" SplitterResultListGetDebugText(splitter_result_list) "] (" splitter_result_list.Length() "/" ime_splitted_list.Length() ")" 
    ImeProfilerEnd(profile_text)

    candidate := ImeCandidateUpdateResult(splitter_result_list)
    ImeSelectorUnlockWords(caret_splitted_index, false)
    ImeSelectorFixupSelectIndex(candidate)
}

ImeInputterIsInputDirty()
{
    global ime_input_is_dirty
    ; Because of we update tranlsator immediately when input update, `ime_input_is_dirty` should always be false
    Assert(ime_input_is_dirty == false, "", false)
    return ime_input_is_dirty
}

;*******************************************************************************
; Get split index
ImeInputterGetCaretSplitIndex()
{
    global ime_input_caret_pos
    global ime_splitted_list
    return SplitterResultListGetIndex(ime_splitted_list, ime_input_caret_pos)
}

ImeInputterCaretSplitIndexIsEnd()
{
    global ime_input_caret_pos
    global ime_splitted_list
    ; global ime_input_string
    ; MsgBox, % ime_splitted_list.Length() "," ime_input_caret_pos "," StrLen(ime_input_string)
    return SplitterResultGetEndPos(ime_splitted_list[ime_splitted_list.Length()]) == ime_input_caret_pos
}

;*******************************************************************************
;
ImeInputterHasAnyInput()
{
    global ime_input_string
    return ime_input_string != ""
}

ImeInputterCaretIsAtEnd()
{
    global ime_input_string
    global ime_input_caret_pos
    return ime_input_caret_pos == StrLen(ime_input_string)
}

ImeInputterCaretIsAtBegin()
{
    global ime_input_caret_pos
    return ime_input_caret_pos == 0
}

;*******************************************************************************
; Caret
ImeInputterCaretMove(dir)
{
    global ime_input_string
    global ime_input_caret_pos
    ime_input_caret_pos := InputterCaretMove(ime_input_caret_pos, dir, ime_input_string)
}

ImeInputterCaretMoveSmartRight()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list
    ime_input_caret_pos := InputterCaretMoveSmartRight(ime_input_caret_pos, ime_input_string, ime_splitted_list)
}

ImeInputterCaretMoveByWord(dir, graceful:=true)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list
    ime_input_caret_pos := InputterCaretMoveByWord(ime_input_caret_pos, dir, graceful, ime_input_string, ime_splitted_list)
}

ImeInputterCaretMoveToHome()
{
    global ime_input_caret_pos
    ime_input_caret_pos := 0
}

ImeInputterCaretMoveToEnd()
{
    global ime_input_string
    global ime_input_caret_pos
    ime_input_caret_pos := StrLen(ime_input_string)
}

ImeInputterCaretMoveToIndex(index)
{
    global ime_input_caret_pos
    global ime_splitted_list
    ime_input_caret_pos := InputterCaretMoveToIndex(ime_input_caret_pos, index, ime_splitted_list)
}

;*******************************************************************************
; Static
ImeInputterGetLastWordPos()
{
    global ime_splitted_list
    if( ime_splitted_list.Length() <= 1 ){
        return 0
    }
    return SplitterResultGetEndPos(ime_splitted_list[ime_splitted_list.Length()-1])
}
