;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_string     := ""               ; 輸入字符
    global ime_input_caret_pos  := 0                ; 光标位置
}

ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ImeProfilerClear()
    ImeTranslatorClear()
    return
}

ImeInputterClearPrevSplitted()
{
    local
    global ime_input_string
    global ime_input_caret_pos

    check_index := ime_input_caret_pos

    if( check_index != 0 )
    {
        left_pos := ImeTranslatorGetLeftWordPos(check_index)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)

        ImeSelectorResetSelectIndex()
        ImeInputterUpdateString(ime_input_string)
        ime_input_caret_pos := left_pos
    }
}

ImeInputterClearLastSplitted()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_caret_pos := ImeTranslatorGetLastWordPos()
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
    if( ImeSelectorIsOpen() || IsSymbol(input_char) )
    {
        input_char := Format("{:U}", input_char)
        ImeSelectorResetSelectIndex()
    }

    caret_pos := ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, caret_pos) . input_char . SubStr(ime_input_string, caret_pos+1)
    ime_input_caret_pos := caret_pos + 1

    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(input_char)
        ImeInputterClearString()
    } else {
        ImeSelectorResetSelectIndex()
        if( IsRadical(input_char) || IsTone(input_char) || IsSymbol(input_char) )
        {
            ImeInputterUpdateString(ime_input_string)
        }
    }
}

;*******************************************************************************
; Input caret
ImeInputterCaretMove(dir, by_word:=false)
{
    global ime_input_caret_pos
    global ime_input_string

    if( by_word )
    {
        if( dir > 0 ){
            word_pos := ImeTranslatorGetRightWordPos(ime_input_caret_pos)
        } else {
            word_pos := ImeTranslatorGetLeftWordPos(ime_input_caret_pos)
        }
        ime_input_caret_pos := word_pos
    }
    else
    {
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
ImeInputterUpdateString(input_string, on_backspace := false)
{
    if( on_backspace ) {
        input_string := RegExReplace(input_string, "[12345' ]([^12345' ]+?)$", "", replace_count)
        if( replace_count != 1 ){
            input_string := ""
        }
    }
    ImeTranslatorUpdateInputString(input_string)
}
