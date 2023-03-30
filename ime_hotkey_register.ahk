;*******************************************************************************
; Hotkeys register
ImeHotkeyRegisterInitialize()
{
    local
    ; symbol
    symbol_ctrl_start_hotkey := {"^``":"``", "^+``":"～", "^+1":"！", "^+2":"＠", "^+3":"#", "^+4":"$", "^+5":"％"
    , "^+6":"……", "^+7":"＆", "^+8":"＊", "^+9":"「", "^+0":"」", "^-":"－", "^+-":"——", "^=":"＝", "^+=":"＋"
    , "^[":"【", "^]":"】", "^+[":"（", "^+]":"）", "^\":"、", "^;":"；", "^+;": "：", "^'":"＇", "^+'":"＂"
    , "^+,":"《","^+.":"》", "^,":"，", "^.":"。", "^+/":"？" }
    global symbol_list_string := ""

    ime_is_waiting_input_fn := Func("ImeStateWaitingInput").Bind()
    Hotkey if, % ime_is_waiting_input_fn
    {
        ; symbol
        for key, char in symbol_ctrl_start_hotkey
        {
            func := Func("HotkeyOnSymbol").Bind(char)
            Hotkey, %key%, %func%
            symbol_list_string .= char
        }
        loop 26
        {
            ; a-z
            func := Func("HotkeyOnAlphabet").Bind(Chr(96+A_Index))
            Hotkey, % Chr(96+A_Index), %func%
        }
    }
    Hotkey, if,

    ime_has_any_input_fn := Func("ImeInputterHasAnyInput").Bind()
    Hotkey, if, % ime_has_any_input_fn
    {
        ; Space and ' to spilt word
        func := Func("HotkeyOnSpace")
        Hotkey, Space, %func%
        func := Func("HotkeyOnSplitMark").Bind("'")
        Hotkey, ', %func%
        func := Func("HotkeyOnSplitMark").Bind("'")
        Hotkey, \, %func%
        func := Func("HotkeyOnSplitMark").Bind("'")
        Hotkey, `;, %func%
        ; 0-9
        loop 10 {
            func := Func("HotkeyOnNumber").Bind(A_Index-1)
            Hotkey, % A_Index-1, %func%
            Hotkey, % "Numpad" A_Index-1, %func%
        }
        loop 26
        {
            ; A-Z
            func := Func("HotkeyOnAlphabet").Bind(Format("{:U}", Chr(96+A_Index)))
            Hotkey, % "+" Chr(96+A_Index), %func%

            ; Ctrl + Shift + A-Z
            func := Func("HotkeyOnCtrlAlphabet").Bind(Chr(96+A_Index), false)
            Hotkey, % "^" Chr(96+A_Index), %func%
            func := Func("HotkeyOnCtrlAlphabet").Bind(Chr(96+A_Index), true)
            Hotkey, % "^+" Chr(96+A_Index), %func%
        }
    }
    Hotkey, if,
    return
}

ImeHotkeyShiftSetMode(orgin_mode)
{
    global ime_input_string
    if( orgin_mode == "en" ){
        if ( ime_input_string ) {
            PutCharacter(ime_input_string)
            ImeInputterClearString()
            ImeSelectorOpen(false)
        }
    }
    ImeStateUpdateMode(orgin_mode)
}

ImeHotkeyRegisterShift(origin_state)
{
    global ime_hotkey_on_shift_set_mode
    static ime_is_waiting_input_fn := Func("ImeStateWaitingInput").Bind()

    ime_hotkey_on_shift_set_mode := Func("HotkeyOnShift").Bind(origin_state)
    if( !ImeModeIsEnglish() ) {
        Hotkey, If, % ime_is_waiting_input_fn
        Hotkey, Shift, % ime_hotkey_on_shift_set_mode, On
        Hotkey, If
    } else {
        Hotkey, Shift, % ime_hotkey_on_shift_set_mode, On
    }
}

ImeHotkeyInitialize()
{
    global ime_hotkey_on_shift_set_mode := ""
}

ImeHotkeyShiftDown()
{
    global ime_hotkey_on_shift_set_mode
    ime_hotkey_on_shift_set_mode.Call()
}
