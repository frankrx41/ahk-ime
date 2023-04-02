;*******************************************************************************
; Hotkey
; Normal input
HotkeyOnAlphabet(char)
{
    ImeInputterProcessChar(char)
    ImeTooltipUpdate()
}

HotkeyOnSplitMark(char)
{
    ImeInputterProcessChar(char)
    ImeTooltipUpdate()
}

HotkeyOnNumber(char)
{
    local
    if( ImeSelectMenuIsOpen() )
    {
        ; Select index
        index := Floor((ImeSelectorGetCaretSelectIndex()-1) / ImeSelectMenuGetColumn()) * ImeSelectMenuGetColumn()
        index += (char == 0 ? 10 : char)
        ImeSelectorSetCaretSelectIndex(index)
        ImeSelectMenuClose()
        ImeSelectorApplyCaretSelectIndex(true)
    }
    else
    {
        ; Input digit
        ImeInputterProcessChar(char)
    }
    ImeTooltipUpdate()
}

HotkeyOnSymbol(char)
{
    loop % StrLen(char)
    {
        ImeInputterProcessChar(SubStr(char, A_Index, 1), true)
    }
    ImeTooltipUpdate()
}

;*******************************************************************************
; Function key
HotkeyOnCtrlAlphabet(char, shift_down)
{
    local
    ; TODO: add rollback
    back_to_front := shift_down ? false : true
    ImeInputterCaretMoveToChar(char, back_to_front)
    ImeTooltipUpdate()
}

HotkeyOnEsc()
{
    static last_esc_tick := 0

    if( ImeSelectMenuIsOpen() ) {
        if( ImeSelectMenuIsMultiple() ) {
            ImeSelectMenuOpen()
        } else {
            ImeSelectMenuClose()
            ImeSelectorCancelCaretSelectIndex()
        }
    } else {
        ; Double esc clear all input
        ; else remove only last
        if( A_TickCount - last_esc_tick < 1000 ){
            ImeInputterClearString()
        } else {
            ImeInputterClearLastSplitted()
        }
        last_esc_tick := A_TickCount
    }
    ImeTooltipUpdate()
}

HotkeyOnShift(orgin_mode)
{
    ; Fix when use {Shift} + {Numpad1} send {NumpadEnd}
    ; system will set {Shift up} event
    static shift_down_tick := A_TickCount
    if( GetKeyState("RShift", "P") ) {
        shift_down_tick := A_TickCount
        return
    }
    if( A_TickCount - shift_down_tick < 1000 ){
        return
    }

    if( ImeSelectMenuIsOpen() ) {
        ImeSelectorToggleSingleMode()
    }
    else {
        ImeHotkeyShiftSetMode(orgin_mode)
    }
    ImeTooltipUpdate()
}

HotkeyOnSpace()
{
    if( ImeSelectMenuIsOpen() ) {
        ImeSelectorToggleSingleMode()
    }
    else {
        ImeInputterProcessChar(" ")
    }
    ImeTooltipUpdate()
}
