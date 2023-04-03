;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_dirty
    global ime_inputter_splitter_result := []

    ImeInputterClearString()
}

;*******************************************************************************
; Enter port
ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_dirty
    global ime_inputter_splitter_result

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ime_input_dirty     := true
    ime_inputter_splitter_result := []
    ImeSelectorClear()
    ImeTranslatorClear()
    return
}

ImeInputterClearPrevSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_inputter_splitter_result

    if( ime_input_caret_pos != 0 )
    {
        left_pos := SplittedIndexsGetLeftWordPos(ime_inputter_splitter_result, ime_input_caret_pos)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := left_pos
    }

    ImeSelectorSetCaretSelectIndex(1)
    ImeInputterUpdateString("", true)
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
        ImeInputterUpdateString("", true)
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
        ImeInputterUpdateString("", true)
    }
    if( !delet_before && ime_input_caret_pos != StrLen(ime_input_string) )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos) . SubStr(ime_input_string, ime_input_caret_pos+2)
        ImeInputterUpdateString("", true)
    }
}

ImeInputterProcessChar(input_char, immediate_put:=false)
{
    global ime_input_caret_pos
    global ime_input_string

    if( ImeSelectMenuIsOpen() )
    {
        input_char := Format("{:U}", input_char)
        ImeSelectorSetCaretSelectIndex(1)
    }
    if( IsSymbol(input_char) )
    {
        ; TODO: We should update result when symbol, like ma？ -> 吗？ de。 -> 的。
    }

    caret_pos := ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, caret_pos) . input_char . SubStr(ime_input_string, caret_pos+1)
    ime_input_caret_pos := caret_pos + 1

    if( immediate_put && StrLen(ime_input_string) == 1 ) {
        PutCharacter(input_char)
        ImeInputterClearString()
    } else {
        ImeInputterUpdateString(input_char)
    }
}

;*******************************************************************************
; Update result
ImeInputterUpdateString(input_char, is_delete:=false)
{
    local
    global ime_input_string
    global ime_inputter_splitter_result
    global ime_input_dirty

    ime_input_dirty := true
    ImeProfilerClear()

    if( ime_input_string )
    {
        ; If no input_char or input_char is not alphabet, try update
        ; no input_char and not is_delete means caller what force call translator
        if( input_char ) {
            should_update := !InStr("qwertyuiopasdfghjklzxcvbnm?", input_char, true)
        } else {
            should_update := true
        }

        ; Splitter
        ime_inputter_splitter_result := PinyinSplitterInputString(ime_input_string)
        ; Translator
        if( should_update ) {
            ImeInputterCallTranslator(is_delete)
        }
    }
    else
    {
        ImeInputterClearString()
    }

    ; Because `is_delete` only update prev string, it always be dirty
    if( is_delete ) {
        ime_input_dirty := true
        Assert(input_char == "")
    }
}

ImeInputterCallTranslator(is_delete)
{
    global ime_inputter_splitter_result
    global ime_input_string
    global ime_input_dirty

    ImeProfilerBegin(12)
    profile_text := ""

    caret_splitted_index := ImeInputterGetCaretSplitIndex()

    splitter_result := []
    loop,% ime_inputter_splitter_result.Length()
    {
        if( is_delete && A_Index >= caret_splitted_index ){
            break
        }
        splitter_result[A_Index] := ime_inputter_splitter_result[A_Index]
    }
    profile_text .= "[" SplitterResultGetDisplayText(splitter_result) "] (" splitter_result.Length() "/" ime_inputter_splitter_result.Length() ")" 
    ImeProfilerEnd(12, profile_text)

    ImeTranslatorUpdateResult(splitter_result)
    ImeSelectorUnlockWords(caret_splitted_index, is_delete)
    ImeSelectorFixupSelectIndex()

    ime_input_dirty := false
}

ImeInputterIsInputDirty()
{
    global ime_input_dirty
    return ime_input_dirty
}

;*******************************************************************************
; Get split index
ImeInputterGetCaretSplitIndex()
{
    global ime_input_caret_pos
    global ime_inputter_splitter_result

    return SplittedIndexsGetPosIndex(ime_inputter_splitter_result, ime_input_caret_pos)
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
    tooltip_string .= "(" ime_input_caret_pos ")"
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

; graceful: take a white space move as a step
ImeInputterCaretMoveByWord(dir, graceful:=false)
{
    global ime_input_caret_pos
    global ime_input_string

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
                word_pos := ImeInputterGetRightWordPos(word_pos)
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
                    word_pos := ImeInputterGetLeftWordPos(word_pos)
                }
            }
        }
    }
    ime_input_caret_pos := word_pos
}

ImeInputterCaretMoveToChar(char, back_to_front)
{
    local
    global ime_input_caret_pos
    global ime_input_string

    input_string := ime_input_string
    origin_index := ime_input_caret_pos
    if( back_to_front ) {
        start_index := origin_index - StrLen(input_string)
    } else {
        start_index := origin_index + 2
    }
    index := InStr(input_string, char, false, start_index)
    if( index != 0 )
    {
        ime_input_caret_pos := index - 1
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

;*******************************************************************************
; Static
ImeInputterGetLastWordPos()
{
    global ime_inputter_splitter_result
    if( ime_inputter_splitter_result.Length() <= 1 ){
        return 0
    }
    return SplitterResultGetEndPos(ime_inputter_splitter_result, ime_inputter_splitter_result.Length()-1)
}

ImeInputterGetLeftWordPos(start_index)
{
    local
    global ime_inputter_splitter_result
    return SplittedIndexsGetLeftWordPos(ime_inputter_splitter_result, start_index)
}

ImeInputterGetRightWordPos(start_index)
{
    local
    global ime_inputter_splitter_result

    return SplittedIndexsGetRightWordPos(ime_inputter_splitter_result, start_index)
}
