;*******************************************************************************
; 全局变量
ImeInitialize:
ime_mode_language := "cn"       ; "cn", "en", "tw"

ime_input_string := ""          ; 輸入字符
ime_input_caret_pos := 0        ; 光标位置
ime_tooltip_pos := ""           ; 输入法提示框光标位置 {x:0,y:0,h:0,t:"",Hwnd:Hwnd}

ime_select_index := 1       ; 选定的候选词，从 1 开始
ime_max_select_cnt := 9     ; 最大候选词个数
ime_candidate_sentences := [] ; 候选句子
ime_open_select_menu := 0   ; 是否打开选字窗口

ime_is_active_system_menu := 0  ; 是否打开菜单
ime_active_window_class := ""   ; 禁用 IME 的窗口是否被激活
ime_opt_pause_window_name_list  := ["Windows.UI.Core.CoreWindow"] ; 禁用 IME 的窗口列表

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
;
EventProcHook(phook, msg, hwnd)
{
    global ime_active_window_class
    global ime_is_active_system_menu

    if (A_IsSuspended)
        return
    switch msg
    {
    case 0x03:                  ; EVENT_SYSTEM_FOREGROUND
        WinGetClass, win_class, ahk_id %hwnd%
        ime_active_window_class := win_class
        ImeUpdateActiveState()
    case 0x06:                  ; EVENT_SYSTEM_MENUPOPUPSTART
        ime_is_active_system_menu := 1
        ImeUpdateActiveState()
    case 0x07:                  ; EVENT_SYSTEM_MENUPOPUPEND
        ime_is_active_system_menu := 0
        ImeUpdateActiveState()
    }
    return
}

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

;*******************************************************************************
; Ime state
ImeUpdateActiveState(mode := "")
{
    if(A_IsSuspended || ImeIsPauseWindowActive()){
        mode := ""
        ImeClearInputString()
    } else {
        global ime_mode_language
        mode := mode ? mode : ime_mode_language
        ImeSetModeLanguage(mode)
        ImeUpdateModeHotkey()
    }

    ImeTooltipUpdate()
    ImeSetIconState(mode)
}

ImeIsPauseWindowActive()
{
    ; 菜单打开时，暂停 IME
    global ime_is_active_system_menu
    if( ime_is_active_system_menu ) {
        return 1
    }
    ; 当前激活的窗口的 class 在禁用列表中，暂停 IME
    global ime_active_window_class
    global ime_opt_pause_window_name_list
    for index, name in ime_opt_pause_window_name_list {
        if( name == ime_active_window_class ) {
            return 1
        }
    }
    return 0
}

ImeIsWaitingInput()
{
    return ImeModeIsChinese() && !ImeIsPauseWindowActive()
}

ImeSetModeLanguage(mode)
{
    global ime_mode_language
    switch (mode) {
    case "cn", "en", "tw":  ime_mode_language := mode
    default:                ime_mode_language := "en"
    }
    return
}

ImeUpdateModeHotkey()
{
    func_to_cn := Func("ImeSetModeLanguageByHotkey").Bind("cn")
    func_to_en := Func("ImeSetModeLanguageByHotkey").Bind("en")
    if( ImeModeIsChinese() ) {
        ime_is_waiting_input_fn := Func("ImeIsWaitingInput").Bind()
        Hotkey, Shift, % func_to_cn, Off
        Hotkey, If, % ime_is_waiting_input_fn
        Hotkey, Shift, % func_to_en, On
        Hotkey, If
    } else {
        Hotkey, Shift, % func_to_en, Off
        Hotkey, Shift, % func_to_cn, On
    }
}

ImeSetModeLanguageByHotkey(mode)
{
    global ime_mode_language

    if( mode == "en" ){
        CallBackBeforeToggleEn()
    }
    ImeSetModeLanguage(mode)
    ImeUpdateModeHotkey()
    ImeTooltipUpdate()
    ImeSetIconState(mode)
    return
}

ImeModeIsChinese()
{
    global ime_mode_language
    return ime_mode_language == "cn" || ime_mode_language == "tw"
}

ImeOpenSelectMenu(open)
{
    global ime_open_select_menu
    global ime_select_index

    ime_open_select_menu := open
    ime_select_index := 1
    return
}

ImeSetIconState(mode)
{
    local
    static ime_opt_icon_path := "ime.icl"
    tooltip_option := "X2300 Y1200"
    if( !mode ){
        ToolTip(4, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        switch (mode) {
        case "cn": info_text := "中", tooltip_option := tooltip_option . " Q1 Bff4f4f Tfefefe"
        case "en": info_text := "英", tooltip_option := tooltip_option . " Q1 B1e1e1e T4f4f4f"
        case "tw": info_text := "漢", tooltip_option := tooltip_option . " Q1 B1e1e1e T4f4f4f"
        }
        ToolTip(4, info_text, tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
