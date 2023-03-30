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

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ime_input_dirty := true
    ImeProfilerClear()
    ImeInputterUpdateString("")
    return
}

ImeInputterClearPrevSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_inputter_split_indexs

    ime_input_string := ImeInputStringClearPrevSplitted(ime_input_string, ime_inputter_split_indexs, ime_input_caret_pos)

    ImeSelectorResetSelectIndex()
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
        ImeSelectorOpen(false)
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ImeSelectorResetSelectIndex()
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
    if( ImeSelectorIsOpen() )
    {
        input_char := Format("{:U}", input_char)
        ImeSelectorResetSelectIndex()
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
    global ime_input_caret_pos
    global ime_input_string
    global ime_inputter_split_indexs
    global ime_input_dirty

    ImeProfilerBegin(6, true)
    should_update_result := false
    if( input_char ) {
        ime_input_dirty := true
        should_update_result := IsRadical(input_char) || IsTone(input_char) || IsSymbol(input_char) || ime_input_caret_pos != StrLen(ime_input_string)
    }
    else
    {
        ime_input_dirty := true
        should_update_result := true
    }

    if( is_delet ) {
        ime_input_dirty := true
        should_update_result := true
    }

    debug_info := ""
    input_split := PinyinSplitInputString(ime_input_string, ime_inputter_split_indexs, radical_list)
    if( should_update_result && ime_input_dirty )
    {
        debug_info .= "[UPDATE] "
        if( is_delet ){
            index := ImeInputterGetCaretSplitIndex()
            radical_list.RemoveAt(index, radical_list.Length() - index + 1)
            debug_info .= "Index: " index " "
        }
        ImeTranslatorUpdateResult(input_split, radical_list)
        ime_input_dirty := false
    }
    debug_info .= "Dirty:" ime_input_dirty " "
    debug_info .= "Delete:" is_delet " "
    debug_info .= "[" radical_list.Length() "/" ime_inputter_split_indexs.Length() "]"
    ImeProfilerEnd(6, debug_info)
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
ImeInputterGetInputString()
{
    global ime_input_string
    return ime_input_string
}

ImeInputterHasAnyInput()
{
    global ime_input_string
    return ime_input_string != ""
}

ImeInputterGetCaretPos()
{
    global ime_input_caret_pos
    return ime_input_caret_pos
}

ImeInputterCaretIsAtEnd()
{
    global ime_input_string
    global ime_input_caret_pos
    return ime_input_caret_pos != StrLen(ime_input_string)
}

;*******************************************************************************
; Move caret
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

ImeInputterCaretMoveByWord(dir)
{
    global ime_input_caret_pos
    global ime_input_string

    move_count := dir > 0 ? dir : (-1 * dir)
    if( dir > 0 ){
        if( ime_input_caret_pos == StrLen(ime_input_string) ){
            word_pos := 0
        } else {
            word_pos := ime_input_caret_pos
            loop, % move_count
            {
                word_pos := ImeInputterGetRightWordPos(word_pos)
            }
            ; if( word_pos == ime_input_caret_pos ){
            ;     word_pos := StrLen(ime_input_string)
            ; }
        }
    } else {
        if( ime_input_caret_pos == 0 ){
            word_pos := StrLen(ime_input_string)
        } else {
            word_pos := ime_input_caret_pos
            loop, % move_count
            {
                word_pos := ImeInputterGetLeftWordPos(word_pos)
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
