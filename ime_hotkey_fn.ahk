;*******************************************************************************
; Ime hotkeys
ImeRegisterHotkey()
{
    local
    ; symbol
    symbol_ctrl_start_hotkey := {"^``":"``", "^+``":"～", "^+1":"！", "^+2":"＠", "^+3":"#", "^+4":"$", "^+5":"％"
    , "^+6":"……", "^+7":"＆", "^+8":"＊", "^+9":"「", "^+0":"」", "^-":"－", "^+-":"——", "^=":"＝", "^+=":"＋"
    , "^[":"【", "^]":"】", "^+[":"（", "^+]":"）", "^\":"、", "^;":"；", "^+;": "：", "^'":"＇", "^+'":"＂"
    , "^+,":"《","^+.":"》", "^,":"，", "^.":"。", "^+/":"？" }

    ime_is_waiting_input_fn := Func("ImeIsWaitingInput").Bind()
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
