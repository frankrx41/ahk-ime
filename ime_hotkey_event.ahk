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
    if( ImeSelectorIsOpen() )
    {
        ; Select index
        index := Floor((ImeSelectorGetSelectIndex()-1) / ImeSelectorGetColumn()) * ImeSelectorGetColumn()
        index += (char == 0 ? 10 : char)
        ImeSelectorSetSelectIndex(index)
        ImeSelectorOpen(false)
        ImeSelectorFixupSelectIndex()
    }
    else
    {
        ; Input digit
        ImeInputterProcessChar(char)
    }
    ImeTooltipUpdate()
}

HotkeyOnCtrlAlphabet(char, shift_down)
{
    local
    ; TODO: add rollback
    back_to_front := shift_down ? false : true
    ImeInputterCaretFastMoveAt(char, back_to_front)
    ImeTooltipUpdate()
}

HotkeyOnBackSpace()
{
    ImeInputterRemoveCurrentChar(true)
    ImeTooltipUpdate()
}

HotkeyOnEsc()
{
    static last_esc_tick := 0

    if( ImeSelectorIsOpen() ) {
        if( ImeSelectorShowMultiple() ) {
            ImeSelectorOpen(true, false)
        } else {
            ImeSelectorFixupSelectIndex()
            ImeSelectorOpen(false)
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

    ImeHotkeyShiftSetMode(orgin_mode)
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

HotkeyOnSymbol(char)
{
    loop % StrLen(char)
    {
        ImeInputterProcessChar(SubStr(char, A_Index, 1), true)
    }
    ImeTooltipUpdate()
}
