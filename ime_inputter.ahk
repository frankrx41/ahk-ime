;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_string     := ""               ; 輸入字符
    global ime_input_caret_pos  := 0                ; 光标位置
    global ime_inputter_split_indexs := []
}

ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_string    := ""
    ime_input_caret_pos := 0
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
    ImeInputterUpdateString(ime_input_string)
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
        ImeInputterUpdateString(ime_input_string)
    }
}

ImeInputterProcessChar(input_char, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string

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

    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(input_char)
        ImeInputterClearString()
    } else {
        ImeSelectorResetSelectIndex()
        if( IsRadical(input_char) || IsTone(input_char) || IsSymbol(input_char) || ime_input_caret_pos != StrLen(ime_input_string) )
        {
            ImeInputterUpdateString(ime_input_string)
        }
        else
        {
            ImeInputterPinyinSplitPos()
        }
    }
}

;*******************************************************************************
;
ImeInputterPinyinSplitPos()
{
    global ime_input_string
    global ime_inputter_split_indexs
    PinyinSplitInpuString(ime_input_string, ime_inputter_split_indexs, "")
}

ImeInputterGetPosSplitIndex()
{
    global ime_input_caret_pos
    global ime_inputter_split_indexs

    return ImeInputStringGetPosSplitIndex(ime_input_caret_pos, ime_inputter_split_indexs)
}

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

;*******************************************************************************
; Input caret
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

ImeInputterCaretFastMoveAt(char, back_to_front)
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

ImeInputterCaretMoveHome(move_home)
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
;
ImeInputterUpdateString(input_string, on_backspace:=false, force:=false)
{
    static last_input_string := ""
    if( !force && input_string == last_input_string ){
        return false
    }
    if( on_backspace ) {
        ; Remove input string last string
        input_string := RegExReplace(input_string, "[12345' ]([^12345' ]+?)$", "", replace_count)
        if( replace_count != 1 ){
            last_char := SubStr(input_string, 0, 1)
            if( !IsTone(last_char) && !IsRadical(last_char) )
            {
                input_string := ""
            }
        }
    }
    last_input_string := input_string

    global ime_input_string
    global ime_inputter_split_indexs
    input_split := PinyinSplitInpuString(input_string, ime_inputter_split_indexs, radical_list)
    ImeTranslatorUpdateResult(input_split, radical_list)
    return true
}
