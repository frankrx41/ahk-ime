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
    global tooltip_debug

    ime_input_string    := ""
    ime_input_caret_pos := 0
    tooltip_debug       := []
    TranslatorClear()
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
        left_pos := TranslatorGetLeftWordPos(check_index)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)

        ImeSelectorSetSelectIndex(1)
        ImeInputterUpdateString(ime_input_string)
        ime_input_caret_pos := left_pos
    }
}

ImeInputterClearLastSplitted()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_caret_pos := TranslatorGetLastWordPos()
    if( ime_input_caret_pos == 0 )
    {
        ImeInputterClearString()
        ImeSelectorOpen(false)
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ImeSelectorSetSelectIndex(1)
        ImeInputterUpdateString(ime_input_string)
    }
}

ImeInputterProcessChar(input_char, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global tooltip_debug

    tooltip_debug := []
    if( ImeSelectorIsOpen() || InStr("QWERTYPASDFGHJKLZXCBNM", input_char, true) )
    {
        if( !ImeSelectorIsOpen() || InStr("qwertyuiopasdfghjklzxcvbnm", input_char) )
        {
            ImeSelectorSetSelectIndex(1)
            ImeInputterUpdateRadical(ImeInputterGetRadical() . input_char)
        }
    }
    else
    {
        caret_pos := ime_input_caret_pos
        ime_input_string := SubStr(ime_input_string, 1, caret_pos) . input_char . SubStr(ime_input_string, caret_pos+1)
        ime_input_caret_pos := caret_pos + 1

        ImeSelectorOpen(false)
        if( try_puts && StrLen(ime_input_string) == 1 ) {
            PutCharacter(input_char)
            ImeInputterClearString()
        } else {
            ImeSelectorSetSelectIndex(1)
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
            word_pos := TranslatorGetRightWordPos(ime_input_caret_pos)
        } else {
            word_pos := TranslatorGetLeftWordPos(ime_input_caret_pos)
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

;*******************************************************************************
;
ImeInputterGetRadical()
{
    return TranslatorGetInputRadical()
}

ImeInputterUpdateRadical(input_radical)
{
    TranslatorUpdateInputRadical(input_radical)
}

ImeInputterUpdateString(input_string)
{
    TranslatorUpdateInputString(input_string)
}