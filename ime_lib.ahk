;*******************************************************************************
; 全局变量
ImeInitialize:
ime_input_string := ""          ; 輸入字符
ime_input_caret_pos := 0        ; 光标位置

ime_tooltip_pos := ""           ; 输入法提示框光标位置 {x:0,y:0,h:0,t:"",Hwnd:Hwnd}

ImeSelectInitialize()
ImeStateInitialize()

ime_tooltip_font_size           := 13
ime_tooltip_font_family         := "Microsoft YaHei Mono" ;"Ubuntu Mono derivative Powerline"
ime_tooltip_font_bold           := false
ime_tooltip_background_color    := "373832"
ime_tooltip_text_color          := "d4d4d4"

symbol_ctrl_start_hotkey := {"^``":"``", "^+``":"～", "^+1":"！", "^+2":"＠", "^+3":"#", "^+4":"$", "^+5":"％"
, "^+6":"……", "^+7":"＆", "^+8":"＊", "^+9":"「", "^+0":"」", "^-":"－", "^+-":"——", "^=":"＝", "^+=":"＋"
, "^[":"【", "^]":"】", "^+[":"（", "^+]":"）", "^\":"、", "^;":"；", "^+;": "：", "^'":"＇", "^+'":"＂"
, "^+,":"《","^+.":"》", "^,":"，", "^.":"。", "^+/":"？" }

; 注册 tooltip 样式
ToolTip(1, "", "Q0 B" ime_tooltip_background_color " T"  ime_tooltip_text_color " S" ime_tooltip_font_size, ime_tooltip_font_family, ime_tooltip_font_bold)
ImeRegisterHotkey()
ImeUpdateActiveState()

DllCall("SetWinEventHook", "UInt", 0x03, "UInt", 0x07, "Ptr", 0, "Ptr", RegisterCallback("EventProcHook"), "UInt", 0, "UInt", 0, "UInt", 0)
PinyinInit()
return

;*******************************************************************************
; Ime hotkeys
ImeRegisterHotkey()
{
    ime_is_waiting_input_fn := Func("ImeIsWaitingInput").Bind()
    Hotkey if, % ime_is_waiting_input_fn
    {
        ; symbol
        global symbol_ctrl_start_hotkey
        for key, char in symbol_ctrl_start_hotkey
        {
            func := Func("ImeInputChar").Bind(char, -1, 1)
            Hotkey, %key%, %func%
        }
        loop 26
        {
            ; a-z
            func := Func("ImeInputChar").Bind(Chr(96+A_Index))
            Hotkey, % Chr(96+A_Index), %func%
            ; A-Z
            func := Func("ImeInputChar").Bind(Format("{:U}", Chr(96+A_Index)))
            Hotkey, % "+" Chr(96+A_Index), %func%
        }
    }
    Hotkey, if,

    Hotkey, if, ime_input_string
    {
        ; Space and ' to spilt word
        func := Func("ImeInputChar").Bind("'", -1, 1)
        Hotkey, Space, %func%
        func := Func("ImeInputChar").Bind("'")
        Hotkey, ', %func%
        ; 0-9
        loop 10 {
            func := Func("ImeInputNumber").Bind(A_Index-1)
            Hotkey, % A_Index-1, %func%
            Hotkey, % "Numpad" A_Index-1, %func%
        }
    }
    Hotkey, if,
    return
}
