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

    ime_is_waiting_input_fn := Func("ImeStateWaitingInput").Bind()
    Hotkey if, % ime_is_waiting_input_fn
    {
        ; symbol
        for key, char in symbol_ctrl_start_hotkey
        {
            func := Func("HotkeyOnChar").Bind(char, -1, 1)
            Hotkey, %key%, %func%
        }
        loop 26
        {
            ; a-z
            func := Func("HotkeyOnChar").Bind(Chr(96+A_Index))
            Hotkey, % Chr(96+A_Index), %func%
        }
    }
    Hotkey, if,

    Hotkey, if, ime_input_string
    {
        ; Space and ' to spilt word
        func := Func("HotkeyOnChar").Bind(" ", -1, 1)
        Hotkey, Space, %func%
        func := Func("HotkeyOnChar").Bind("'")
        Hotkey, ', %func%
        func := Func("HotkeyOnChar").Bind("'")
        Hotkey, \, %func%
        func := Func("HotkeyOnChar").Bind("'")
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
            func := Func("HotkeyOnChar").Bind(Format("{:U}", Chr(96+A_Index)))
            Hotkey, % "+" Chr(96+A_Index), %func%

            func := Func("HotkeyOnCtrlAlpha").Bind(Chr(96+A_Index))
            Hotkey, % "^" Chr(96+A_Index), %func%
            func := Func("HotkeyOnCtrlShiftAlpha").Bind(Chr(96+A_Index))
            Hotkey, % "^+" Chr(96+A_Index), %func%
        }
    }
    Hotkey, if,
    return
}

ImeHotkeyRegisterShift()
{
    func_to_cn := Func("HotkeyOnShift").Bind("cn")
    func_to_en := Func("HotkeyOnShift").Bind("en")
    if( ImeModeIsChinese() ) {
        ime_is_waiting_input_fn := Func("ImeStateWaitingInput").Bind()
        Hotkey, Shift, % func_to_cn, Off
        Hotkey, If, % ime_is_waiting_input_fn
        Hotkey, Shift, % func_to_en, On
        Hotkey, If
    } else {
        Hotkey, Shift, % func_to_en, Off
        Hotkey, Shift, % func_to_cn, On
    }
}
