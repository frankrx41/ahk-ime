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

HotkeyOnBackSpace()
{
    local
    global ime_input_candidate
    global ime_input_string
    global ime_input_caret_pos
    global tooltip_debug
    global DB

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