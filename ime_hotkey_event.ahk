;*******************************************************************************
; Hotkey
HotkeyOnChar(input_char, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
    global tooltip_debug
    global DB

    tooltip_debug := []
    if( ImeIsSelectMenuOpen() || InStr("QWERTYPASDFGHJKLZXCBNM", input_char, true) )
    {
        if( !ImeIsSelectMenuOpen() || InStr("qwertyuiopasdfghjklzxcvbnm", input_char) )
        {
            ime_input_candidate.SetSelectIndex(1)
            ime_input_candidate.UpdateInputRadical(ime_input_candidate.GetInputRadical() . input_char)
        }
        if( input_char == " " && ImeIsSelectMenuOpen() )
        {
            ime_input_candidate.ToggleSingleMode()
        }
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

    ImeTooltipUpdate()
}

HotkeyOnNumber(key)
{
    global ime_input_candidate

    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        start_index := Floor((ime_input_candidate.GetSelectIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
        ime_input_candidate.SetSelectIndex(start_index + (key == 0 ? 10 : key))
        PutCandidateCharacter(ime_input_candidate)
        ImeTooltipUpdate()
    }
    else {
        HotkeyOnChar(key)
    }
}

HotkeyOnCtrlAlpha(char)
{
    global ime_input_caret_pos
    global ime_input_string
    ime_input_caret_pos := ImeInputCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, true)
    ImeTooltipUpdate()
}

HotkeyOnCtrlShiftAlpha(char)
{
    global ime_input_caret_pos
    global ime_input_string
    ime_input_caret_pos := ImeInputCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, false)
    ImeTooltipUpdate()
}

HotkeyOnBackSpace()
{
    local
    global ime_input_candidate
    global ime_input_string
    global ime_input_caret_pos
    global tooltip_debug
    global DB

    input_radical := ime_input_candidate.GetInputRadical()
    if( input_radical ){
        input_radical := SubStr(input_radical, 1, StrLen(input_radical)-1)
        ime_input_candidate.SetSelectIndex(1)
        ime_input_candidate.UpdateInputRadical( input_radical )
        ImeTooltipUpdate()
    }
    else if( ime_input_caret_pos != 0 ){
        tooltip_debug[1] := ""
        tooltip_debug[7] := ""
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ime_input_candidate.Initialize(ime_input_string, DB)
        ImeTooltipUpdate()
    }
}

HotkeyOnEsc()
{
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
    ImeTooltipUpdate()
}

HotkeyOnShift(mode)
{
    if( mode == "en" ){
        CallBackBeforeToggleEn()
    }
    ImeModeSetLanguage(mode)
    ImeHotkeyRegisterShift()
    ImeTooltipUpdate("")
    ImeIconSetMode(mode)
}
