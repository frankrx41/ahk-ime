;*******************************************************************************
; Hotkey
HotkeyOnAlphabet(char)
{
    ImeInputterProcessChar(char)
    ImeTooltipUpdate()
}

HotkeyOnNumber(char)
{
    local
    ; 选择相应的编号并上屏
    if( ImeSelectorIsOpen() ) {
        index := Floor((ImeSelectorGetSelectIndex()-1) / ImeSelectorGetColumn()) * ImeSelectorGetColumn()
        index += (char == 0 ? 10 : char)
        ImeSelectorSetSelectIndex(index)
        PutCandidateCharacter()
        ImeTooltipUpdate()
    }
    else {
        ImeInputterProcessChar(char)
        ImeTooltipUpdate()
    }
}

HotkeyOnCtrlAlphabet(char)
{
    global ime_input_caret_pos
    global ime_input_string
    ime_input_caret_pos := ImeInputterCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, true)
    ImeTooltipUpdate()
}

HotkeyOnCtrlShiftAlphabet(char)
{
    global ime_input_caret_pos
    global ime_input_string
    ime_input_caret_pos := ImeInputterCaretFastMoveAt(char, ime_input_string, ime_input_caret_pos, false)
    ImeTooltipUpdate()
}

HotkeyOnBackSpace()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global tooltip_debug

    input_radical := ImeInputterGetRadical()
    if( input_radical ){
        input_radical := SubStr(input_radical, 1, StrLen(input_radical)-1)
        ImeSelectorSetSelectIndex(1)
        ImeInputterUpdateRadical(input_radical)
        ImeTooltipUpdate()
    }
    else if( ime_input_caret_pos != 0 ){
        tooltip_debug[1] := ""
        tooltip_debug[7] := ""
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeInputterUpdateString(ime_input_string)
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
            ImeInputterClearString()
        } else {
            ImeInputterClearLastSplitted()
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
            ImeInputterClearString()
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
    ImeInputterProcessChar(char)
    ImeTooltipUpdate()
}

HotkeyOnSpace()
{
    if( ImeSelectorIsOpen() ) {
        ImeSelectorToggleSingleMode()
    }
    else {
        ImeInputterProcessChar(" ")
    }
    ImeTooltipUpdate()
}
