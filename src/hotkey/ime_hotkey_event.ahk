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

HotkeyOnShiftAlphabet(char)
{
    if( ImeInputterCaretIsAtBegin() ) {
        ImeInputterCaretMoveToIndex(2)
    }
    ImeInputterProcessChar(char)
    ImeTooltipUpdate()
}

;*******************************************************************************
; Function key
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
            ImeInputterClearAll()
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
    static shift_down_tick  := A_TickCount
    static double_shift     := A_TickCount
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
    if( ImeInputterHasAnyInput() )
    {
        if( A_TickCount - double_shift < 500 ) {
            ImeSchemeSimpleToggle()
            ImeInputterUpdateString("")
        } else {
            double_shift := A_TickCount
        }
    }
    else
    {
        ImeStateUpdateLanague(orgin_mode)
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
