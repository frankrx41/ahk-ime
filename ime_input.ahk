;*******************************************************************************
; Input string
ImeInputClearString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global tooltip_debug

    ime_input_string    := ""
    ime_input_caret_pos := 0
    tooltip_debug := []
    ime_input_candidate.Clear()
    ImeOpenSelectMenu(false)
    return
}

ImeInputClearPrevSplitted(check_index)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global DB

    if( check_index != 0 )
    {
        left_pos := ime_input_candidate.GetLeftWordPos(check_index)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)

        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.Initialize(ime_input_string, DB)
        ime_input_caret_pos := left_pos
    }
}

ImeInputClearLastSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global DB

    ime_input_caret_pos := ime_input_candidate.GetLastWordPos()
    if( ime_input_caret_pos == 0 )
    {
        ImeInputClearString()
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.Initialize(ime_input_string, DB)
    }
}

;*******************************************************************************
; Input caret
ImeInputCaretMove(dir, by_word:=false)
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

ImeInputCaretFastMoveAt(char, input_string, origin_index, back_to_front)
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
