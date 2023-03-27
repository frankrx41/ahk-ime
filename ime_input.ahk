;*******************************************************************************
; 清除输入字符
ImeClearInputString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global tooltip_debug

    ime_input_string    := ""
    ime_input_caret_pos := 0
    tooltip_debug := []
    ime_input_candidate.SetSelectIndex(1)
    ImeOpenSelectMenu(false)
    return
}

ImeClearSplitedInputBefore(check_index)
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

ImeClearLastSplitedInput()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global DB

    ime_input_caret_pos := ime_input_candidate.GetLastWordPos()
    if( ime_input_caret_pos == 0 )
    {
        ImeClearInputString()
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.Initialize(ime_input_string, DB)
    }
}

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

HotkeyOnCtrlAlpha(char)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
    ime_input_caret_pos := ImeInputCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, true)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate, false)
}

HotkeyOnCtrlShiftAlpha(char)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
    ime_input_caret_pos := ImeInputCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, false)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate, false)
}

;*******************************************************************************
; 切换成英文前以原始输入上屏文字
CallBackBeforeToggleEn()
{
    global ime_input_string

    if ( ime_input_string ) {
        PutCharacter(ime_input_string)
        ImeClearInputString()
    }
    return
}

PutCandidateCharacter(candidate)
{
    global ime_input_string
    global ime_input_caret_pos
    global DB

    send_word := candidate.SendWordThenUpdate(DB)
    PutCharacter( send_word )

    before_input_string := ime_input_string
    ime_input_string := candidate.GetRemainString()
    ime_input_caret_pos -= StrLen(before_input_string) - StrLen(ime_input_string)

    if( !ime_input_string )
    {
        ImeClearInputString()
    }
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    global ime_input_candidate
    string := ime_input_candidate.GetWord(select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeClearInputString()
}

;*******************************************************************************
; 输入相关的函数
; 输入标点符号
; 输入字符
; 输入音调
HotkeyOnChar(input_char, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
    global tooltip_debug
    global DB

    update_coord := false
    tooltip_debug := []
    if (!ime_input_string ) {
        update_coord := true
    }
    if( InStr("QWERTYPASDFGHJKLZXCBNM", input_char, true) )
    {
        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.UpdateRadicalCode(ime_input_candidate.GetRadicalCode() . input_char)
    }
    else
    {
        pos := pos != -1 ? pos : ime_input_caret_pos
        ime_input_string := SubStr(ime_input_string, 1, pos) . input_char . SubStr(ime_input_string, pos+1)
        ime_input_caret_pos := pos + 1

        if( try_puts && StrLen(ime_input_string) == 1 ) {
            PutCharacter(input_char)
            ImeClearInputString()
        } else {
            ImeOpenSelectMenu(false)
            ime_input_candidate.SetSelectIndex(1)
            ime_input_candidate.Initialize(ime_input_string, DB)
        }
    }

    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate, update_coord)
}

HotkeyOnNumber(key)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate

    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        start_index := Floor((ime_input_candidate.GetSelectIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
        ime_input_candidate.SetSelectIndex(start_index + (key == 0 ? 10 : key))
        PutCandidateCharacter(ime_input_candidate)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
    }
    else {
        HotkeyOnChar(key)
    }
}

HotkeyOnBackSpace()
{
    local
    global ime_input_candidate
    global ime_input_string
    global ime_input_caret_pos
    global tooltip_debug

    radical_code := ime_input_candidate.GetRadicalCode()
    if( radical_code ){
        radical_code := SubStr(radical_code, 1, StrLen(radical_code)-1)
        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.UpdateRadicalCode( radical_code )
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
    }
    else if( ime_input_caret_pos != 0 ){
        tooltip_debug[1] := ""
        tooltip_debug[7] := ""
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ime_input_candidate.Initialize(ime_input_string, DB)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
    }
}

HotkeyOnEsc()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    static last_esc_tick := 0

    if( ImeIsSelectMenuOpen() ) {
        if( ImeIsSelectMenuMore() ) {
            ImeOpenSelectMenu(true, false)
        } else {
            ImeOpenSelectMenu(false)
        }
    } else {
        if( A_TickCount - last_esc_tick < 1000 ){
            ImeClearInputString()
        } else {
            ImeClearLastSplitedInput()
        }
    }
    last_esc_tick := A_TickCount
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
}
