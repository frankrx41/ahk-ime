;*******************************************************************************
; Hotkey
HotkeyOnAlphabet(char)
{
    ImeInputProcessChar(char)
    ImeTooltipUpdate()
}

HotkeyOnNumber(char)
{
    global ime_input_candidate

    ; 选择相应的编号并上屏
    if( ImeSelectorIsOpen() ) {
        start_index := Floor((ime_input_candidate.GetSelectIndex()-1) / ImeSelectorGetColumn()) * ImeSelectorGetColumn()
        ime_input_candidate.SetSelectIndex(start_index + (char == 0 ? 10 : char))
        PutCandidateCharacter(ime_input_candidate)
        ImeTooltipUpdate()
    }
    else {
        ImeInputProcessChar(char)
        ImeTooltipUpdate()
    }
}

HotkeyOnCtrlAlphabet(char)
{
    global ime_input_caret_pos
    global ime_input_string
    ime_input_caret_pos := ImeInputCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, true)
    ImeTooltipUpdate()
}

HotkeyOnCtrlShiftAlphabet(char)
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

    if( ImeSelectorIsOpen() ) {
        if( ImeSelectorShowMultiple() ) {
            ImeSelectorOpen(true, false)
        } else {
            ImeSelectorOpen(false)
        }
    } else {
        if( A_TickCount - last_esc_tick < 1000 ){
            ImeInputClearString()
        } else {
            ImeInputClearLastSplitted()
        }
        last_esc_tick := A_TickCount
    }
    ImeTooltipUpdate()
}

HotkeyOnShiftSetMode(mode)
{
    global ime_input_string
    if( mode == "en" ){
        if ( ime_input_string ) {
            PutCharacter(ime_input_string)
            ImeInputClearString()
            ImeSelectorOpen(false)
        }
    }
    ImeModeSetLanguage(mode)
    ImeHotkeyRegisterShift()
    ImeTooltipUpdate("")
    ImeIconSetMode(mode)
}

HotkeyOnSplitMark(char)
{
    ImeInputProcessChar(char)
    ImeTooltipUpdate()
}
