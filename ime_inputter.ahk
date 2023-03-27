;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_candidate  := new Translator   ; 候选项
    global ime_input_string     := ""               ; 輸入字符
    global ime_input_caret_pos  := 0                ; 光标位置
}

ImeInputterClearString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global tooltip_debug

    ime_input_string    := ""
    ime_input_caret_pos := 0
    tooltip_debug       := []
    ime_input_candidate.Clear()
    return
}

ImeInputterClearPrevSplitted()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate

    check_index := ime_input_caret_pos

    if( check_index != 0 )
    {
        left_pos := ime_input_candidate.GetLeftWordPos(check_index)
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
    global ime_input_candidate

    ime_input_caret_pos := ime_input_candidate.GetLastWordPos()
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
    global ime_input_candidate

    if( by_word )
    {
        if( dir > 0 ){
            word_pos := ime_input_candidate.GetRightWordPos(ime_input_caret_pos)
        } else {
            word_pos := ime_input_candidate.GetLeftWordPos(ime_input_caret_pos)
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
    global ime_input_candidate
    return ime_input_candidate.GetInputRadical()
}

ImeInputterUpdateRadical(input_radical)
{
    global ime_input_candidate
    ime_input_candidate.UpdateInputRadical(input_radical)
}

ImeInputterUpdateString(input_string)
{
    global ime_input_candidate
    global DB
    ime_input_candidate.Initialize(input_string, DB)
}
