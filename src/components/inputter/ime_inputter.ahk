;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_dirty
    global ime_splitted_list := []

    ImeInputterClearAll()
    ImeInputterHistoryClear()
}

;*******************************************************************************
; Enter port
ImeInputterClearAll()
{
    global ime_input_dirty
    global ime_splitted_list

    ime_input_dirty     := true
    ime_splitted_list   := []
    
    ImeInputterStringClear()
    ImeInputterCaretClear()
    ImeSelectorClear()
    ImeCandidateClear()
    return
}

;*******************************************************************************
; Update result
ImeInputterUpdateString(input_char)
{
    local
    global ime_splitted_list
    global ime_input_dirty

    ime_input_dirty := true
    ImeProfilerClear()
    ImeProfilerBegin(8)

    if( ImeInputterStringGetLegacy() )
    {
        ; Splitter
        if( ImeModeIsChinese() ){
            ime_splitted_list := PinyinSplitterInputString(ImeInputterStringGetLegacy())
        } else
        if( ImeModeIsJapanese() ) {
            ime_splitted_list := GojuonSplitterInputString(ImeInputterStringGetLegacy())
        }
        ; Translator
        ImeInputterCallTranslator()
    }
    else
    {
        ImeInputterClearAll()
    }

    ImeProfilerEnd(8)
}

ImeInputterCallTranslator()
{
    global ime_splitted_list
    global ime_input_dirty

    ImeProfilerBegin(12)
    profile_text := ""

    caret_splitted_index := ImeInputterGetCaretSplitIndex()

    splitter_result_list := CopyObj(ime_splitted_list)
    profile_text .= "[" SplitterResultListGetDisplayText(splitter_result_list) "] (" splitter_result_list.Length() "/" ime_splitted_list.Length() ")" 
    ImeProfilerEnd(12, profile_text)

    candidate := ImeCandidateUpdateResult(splitter_result_list)
    ImeSelectorUnlockWords(caret_splitted_index, false)
    ImeSelectorFixupSelectIndex(candidate)

    ime_input_dirty := false
}

ImeInputterIsInputDirty()
{
    global ime_input_dirty
    ; Because of we update tranlsator immediately when input update, `ime_input_dirty` should always be false
    Assert(ime_input_dirty == false)
    return ime_input_dirty
}

;*******************************************************************************
; Get split index
ImeInputterGetCaretSplitIndex()
{
    global ime_splitted_list
    return SplitterResultListGetIndex(ime_splitted_list, ImeInputterCaretGet())
}

;*******************************************************************************
;
ImeInputterHasAnyInput()
{
    return ImeInputterStringGetLegacy() != ""
}

ImeInputterCaretIsAtEnd()
{
    return ImeInputterCaretGet() == StrLen(ImeInputterStringGetLegacy())
}

ImeInputterCaretIsAtBegin()
{
    return ImeInputterCaretGet() == 0
}

;*******************************************************************************
;
ImeInputterCaretMoveSmartRight()
{
    global ime_splitted_list
    return ImeInputterCaretMoveSmartRightInner(ime_splitted_list)
}

ImeInputterCaretMoveByWord(dir, graceful:=true)
{
    global ime_splitted_list
    return ImeInputterCaretMoveByWordInner(dir, graceful, ime_splitted_list)
}

ImeInputterCaretMoveToIndex(index)
{
    global ime_splitted_list
    return ImeInputterCaretMoveToIndexInner(index, ime_splitted_list)
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
