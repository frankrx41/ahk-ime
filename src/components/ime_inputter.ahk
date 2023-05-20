;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_dirty
    global ime_splitted_list := []
    global ime_input_string_history := []   ; ["select"] := current_index

    ImeInputterClearString()
    ImeInputterHistoryClear()
}

;*******************************************************************************
; Enter port
ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_dirty
    global ime_splitted_list

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ime_input_dirty     := true
    ime_splitted_list   := []
    
    ImeSelectorClear()
    ImeCandidateClear()
    return
}

ImeInputterHistoryClear()
{
    global ime_input_string_history
    ime_input_string_history := []
    ime_input_string_history["select"] := 0
}

ImeInputterClearPrevSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list

    if( ime_input_caret_pos != 0 )
    {
        left_pos := SplitterResultListGetLeftWordPos(ime_splitted_list, ime_input_caret_pos)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := left_pos
    }

    ImeSelectorSetCaretSelectIndex(1)
    ImeInputterUpdateString("")
}

ImeInputterClearLastSplitted()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_caret_pos := ImeInputterGetLastWordPos()
    if( ime_input_caret_pos == 0 )
    {
        ImeInputterClearString()
        ImeSelectMenuClose()
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ImeSelectorSetCaretSelectIndex(1)
        ImeInputterUpdateString("")
    }
}

ImeInputterDeleteCharAtCaret(delet_before := true)
{
    global ime_input_string
    global ime_input_caret_pos

    if( delet_before && ime_input_caret_pos != 0 )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeInputterUpdateString("")
    }
    if( !delet_before && ime_input_caret_pos != StrLen(ime_input_string) )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos) . SubStr(ime_input_string, ime_input_caret_pos+2)
        ImeInputterUpdateString("")
    }
}

ImeInputterProcessChar(input_char, immediate_put:=false)
{
    global ime_input_caret_pos
    global ime_input_string

    if( ImeSelectMenuIsOpen() )
    {
        ; When select menu open, new input always take as radical
        input_char := Format("{:U}", input_char)
        ImeSelectorSetCaretSelectIndex(1)
    }
    if( IsSymbol(input_char) )
    {
        ; TODO: We should update result when symbol, like ma？ -> 吗？ de。 -> 的。
        ; Or move this feature to `SelectorFindGraceResultIndex`
    }

    caret_pos := ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, caret_pos) . input_char . SubStr(ime_input_string, caret_pos+1)
    ime_input_caret_pos := caret_pos + 1

    if( immediate_put && StrLen(ime_input_string) == 1 ) {
        ImeOutputterPutSelect(true)
        ImeInputterClearString()
    } else {
        ImeInputterUpdateString(input_char)
    }
}

;*******************************************************************************
; Update result
ImeInputterUpdateString(input_char)
{
    local
    global ime_input_string
    global ime_splitted_list
    global ime_input_dirty

    ime_input_dirty := true
    ImeProfilerClear()
    ImeProfilerBegin(8)

    if( ime_input_string )
    {
        ; Splitter
        if( ImeModeIsChinese() ){
            ime_splitted_list := PinyinSplitterInputString(ime_input_string)
        } else
        if( ImeModeIsJapanese() ) {
            ime_splitted_list := GojuonSplitterInputString(ime_input_string)
        }
        ; Translator
        ImeInputterCallTranslator()
    }
    else
    {
        ImeInputterClearString()
    }

    ImeProfilerEnd(8)
}

ImeInputterCallTranslator()
{
    global ime_splitted_list
    global ime_input_string
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
    global ime_input_caret_pos
    global ime_splitted_list

    return SplitterResultListGetIndex(ime_splitted_list, ime_input_caret_pos)
}

;*******************************************************************************
;
ImeInputterGetDisplayString()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
    tooltip_string := StrReplace(tooltip_string, " ", "_")
    tooltip_string .= " (" ime_input_caret_pos "|" ImeInputterGetCaretSplitIndex() ")"
    if( ImeInputterIsInputDirty() ){
        tooltip_string .= " {Enter}"
    }
    return tooltip_string
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
; Move caret
; -1 <- | -> +1
ImeInputterCaretMove(dir)
{
    global ime_input_caret_pos
    global ime_input_string

    input_string_len := StrLen(ime_input_string)
    ime_input_caret_pos += dir

    if( ime_input_caret_pos < 0 )
    {
        ime_input_caret_pos := input_string_len
    }
    else
    if( ime_input_caret_pos > input_string_len )
    {
        ime_input_caret_pos := 0
    }
}

; move to initials
ImeInputterCaretMoveSmartRight()
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_splitted_list

    input_string_len := StrLen(ime_input_string)

    loop_count := 1
    current_pos := ime_input_caret_pos
    loop, % loop_count
    {
        last_pos := current_pos
        ; loop
        if( current_pos == input_string_len )
        {
            current_pos := 0
        }

        ; update word index
        if( last_pos == current_pos )
        {
            current_start_pos := SplitterResultListGetCurrentWordPos(ime_splitted_list, current_pos)
            if( current_start_pos == current_pos && InStr("zcs", SubStr(ime_input_string, current_start_pos+1, 1)) )
            {
                if( SubStr(ime_input_string, current_start_pos+2, 1) == "h" )
                {
                    current_pos += 2
                } else {
                    current_pos += 1
                }
            }
            else
            {
                right_pos := SplitterResultListGetRightWordPos(ime_splitted_list, current_pos)
                current_pos := right_pos
            }
        }
    }
    ime_input_caret_pos := current_pos
}

; graceful: take a white space move as a step
ImeInputterCaretMoveByWord(dir, graceful:=true)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_splitted_list

    move_count := dir > 0 ? dir : (-1 * dir)
    if( dir > 0 ){
        if( ime_input_caret_pos == StrLen(ime_input_string) ){
            word_pos := 0
        }
        else {
            word_pos := ime_input_caret_pos
            index := 0
            loop
            {
                if( index == move_count ) {
                    break
                }
                index += 1
                begin_pos := word_pos
                word_pos := SplitterResultListGetRightWordPos(ime_splitted_list, word_pos)
                if( graceful && SubStr(ime_input_string, word_pos, 1) == " " && begin_pos+1 != word_pos ) {
                    word_pos := word_pos-1
                }
            }
        }
    } else {
        if( ime_input_caret_pos == 0 ){
            word_pos := StrLen(ime_input_string)
        } else {
            word_pos := ime_input_caret_pos
            index := 0
            loop
            {
                if( index == move_count ) {
                    break
                }
                if( graceful && SubStr(ime_input_string, word_pos, 1) == " " ) {
                    index += 1
                    word_pos := word_pos-1
                } else {
                    index += 1
                    word_pos := SplitterResultListGetLeftWordPos(ime_splitted_list, word_pos)
                }
            }
        }
    }
    ime_input_caret_pos := word_pos
}

;*******************************************************************************
; Move to
ImeInputterCaretMoveToChar(char, back_to_front, try_rollback:=true)
{
    local
    global ime_input_caret_pos
    global ime_input_string

    loop, 2
    {
        if( A_Index == 1 )
        {
            if( back_to_front ) {
                start_index := ime_input_caret_pos - StrLen(ime_input_string)
            } else {
                start_index := ime_input_caret_pos + 2
            }
        }
        else if( try_rollback )
        {
            if( back_to_front ) {
                start_index := 0
            } else {
                start_index := 1
            }
        }
        index := InStr(ime_input_string, char, false, start_index)
        if( index != 0 ) {
            ime_input_caret_pos := index
            break
        }
    }
}

ImeInputterCaretMoveToHome(move_home)
{
    global ime_input_caret_pos
    global ime_input_string

    if( move_home ){
        ime_input_caret_pos := 0
    } else {
        ime_input_caret_pos := StrLen(ime_input_string)
    }
}

ImeInputterCaretMoveToIndex(index)
{
    global ime_splitted_list
    global ime_input_caret_pos
    if( ime_splitted_list.Length() >= index )
    {
        ime_input_caret_pos := SplitterResultGetStartPos(ime_splitted_list[index])
    }
    else
    {
        ime_input_caret_pos := SplitterResultGetEndPos(ime_splitted_list[index-1])
    }
}

;*******************************************************************************
;
ImeInputterHistorySummon(offset)
{
    global ime_input_string
    global ime_input_string_history
    ; ime_input_string_history.Push(ime_input_string)
    ime_input_string_history["select"] += offset
    if( ime_input_string_history["select"] <= 0 ){
        ime_input_string_history["select"] := ime_input_string_history.Length()
    }
    if( ime_input_string_history["select"] > ime_input_string_history.Length() ){
        ime_input_string_history["select"] := 1
    }
    select_index := ime_input_string_history["select"]
    ime_input_string := ime_input_string_history[select_index]
    ; ToolTip, % ime_input_string ", " select_index ", " ime_input_string_history.Length()
}

ImeInputterHistoryPush()
{
    global ime_input_string_history
    global ime_input_string
    ime_input_string_history.Push(ime_input_string)
    ; ime_input_string_history.Push("{" ime_input_string_history.Length() "}" ime_input_string)
    ; ToolTip, % ime_input_string ", " ime_input_string_history.Length()
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

;*******************************************************************************
;
ImeInputterGetLegacyOutputString()
{
    global ime_input_string
    return ime_input_string
}
