;*******************************************************************************
; Input string
ImeInputterInitialize()
{
    global ime_input_candidate  := new Candidate    ; 候选项
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

ImeInputterClearPrevSplitted(check_index)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate

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

ImeInputterProcessChar(input_char, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
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
        pos := ime_input_caret_pos
        ime_input_string := SubStr(ime_input_string, 1, pos) . input_char . SubStr(ime_input_string, pos+1)
        ime_input_caret_pos := pos + 1

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

ImeInputterCaretFastMoveAt(char, input_string, origin_index, back_to_front)
{
    local

    if( back_to_front ) {
        start_index := origin_index - StrLen(input_string)
    } else {
        start_index := origin_index + 2
    }
    index := InStr(input_string, char, false, start_index)
    if( index != 0 )
    {
        return index - 1
    }
    return origin_index
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