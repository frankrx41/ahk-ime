;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_string         ; 輸入字符
    global ime_input_caret_pos      ; 光标位置
    global ime_inputter_split_indexs := []
    global ime_input_dirty

    ImeInputterClearString()
}

ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_dirty
    global ime_inputter_split_indexs

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ime_input_dirty := true
    ime_inputter_split_indexs := []
    ImeProfilerClear()
    ImeSelectorClear()
    ImeTranslatorClear()
    return
}

ImeInputterClearPrevSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_inputter_split_indexs

    ime_input_string := ImeInputStringClearPrevSplitted(ime_input_string, ime_inputter_split_indexs, ime_input_caret_pos)
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

ImeInputterDeleteAtCaret(delet_before := true)
{
    global ime_input_string
    global ime_input_caret_pos
    ; TODO: add remomve after for {DEL} key
    if( ime_input_caret_pos != 0 )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeInputterUpdateString("", true)
    }
}

ImeInputterProcessChar(input_char, immediate_put:=false)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_inputter_split_indexs

    ImeProfilerClear()
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
ImeInputterUpdateString(input_char, is_delet:=false)
{
    local
    global ime_input_string
    global ime_inputter_split_indexs
    global ime_input_dirty

    should_update_result := false
    ; If no input_char or input_char is not alphabet, try update
    if( input_char ) {
        ime_input_dirty := true
        should_update_result := !InStr("qwertyuiopasdfghjklzxcvbnm?", input_char, true)
    } else {
        ime_input_dirty := true
        should_update_result := true
    }

    if( is_delet ) {
        ime_input_dirty := true
        should_update_result := true
    }

    if( !ime_input_string && is_delet )
    {
        ImeInputterClearString()
    }
    else
    {
        ImeProfilerBegin(12, true)
        debug_info := ""
        Assert(ime_input_string)
        input_split := PinyinSplitInputString(ime_input_string, ime_inputter_split_indexs, radical_list)

        split_index := ImeInputterGetCaretSplitIndex()
        if( is_delet )
        {
            ImeSelectorUnLockFrontLockWord(split_index)
        } else {
            ImeSelectorClearAfter(split_index)
        }

        ; Update result
        if( should_update_result && ime_input_dirty )
        {
            debug_info .= "[" input_split "]"
            if( is_delet && input_split )
            {
                index := ImeInputterGetCaretSplitIndex()
                remove_count := radical_list.Length() - index + 1
                radical_list.RemoveAt(index, remove_count)
                loop, % remove_count
                {
                    input_split := SplitWordRemoveLastWord(input_split)
                }
                debug_info .= "->[" input_split "]"
            }
            ImeTranslatorUpdateResult(input_split, radical_list)
            ime_input_dirty := false
        }
        ; Because `is_delet` only update prev string, it always be dirty
        if( is_delet ) {
            ime_input_dirty := true
        }
        debug_info .= " (" radical_list.Length() "/" ime_inputter_split_indexs.Length() ") dirty: " ime_input_dirty
        ImeProfilerEnd(12, debug_info)
    }
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
    global ime_inputter_split_indexs

    return ImeInputStringGetPosSplitIndex(ime_input_caret_pos, ime_inputter_split_indexs)
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
        else
        if( SubStr(ime_input_string, ime_input_caret_pos-1, 1) == " " )
        {
            word_pos := ime_input_caret_pos-1
        } else {
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
    global ime_inputter_split_indexs
    if( ime_inputter_split_indexs.Length() <= 1 ){
        return 0
    }
    return ime_inputter_split_indexs[ime_inputter_split_indexs.Length()-1]
}

ImeInputterGetLeftWordPos(start_index)
{
    local
    global ime_inputter_split_indexs
    return ImeInputStringGetLeftWordPos(start_index, ime_inputter_split_indexs)
}

ImeInputterGetRightWordPos(start_index)
{
    local
    global ime_inputter_split_indexs

    return ImeInputStringGetRightWordPos(start_index, ime_inputter_split_indexs)
}
