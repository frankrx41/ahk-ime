ImeStateInitialize()
{
    global ime_mode_language
    global ime_is_active_system_menu
    global ime_active_window_class
    global ime_opt_pause_window_name_list
    
    ime_mode_language := "cn"       ; "cn", "en", "tw"
    ime_is_active_system_menu := 0  ; 是否打开菜单
    ime_active_window_class := ""   ; 禁用 IME 的窗口是否被激活
    ime_opt_pause_window_name_list  := ["Windows.UI.Core.CoreWindow"] ; 禁用 IME 的窗口列表

    DllCall("SetWinEventHook", "UInt", 0x03, "UInt", 0x07, "Ptr", 0, "Ptr", RegisterCallback("EventProcHook"), "UInt", 0, "UInt", 0, "UInt", 0)
}

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

    ImeTooltipUpdate("")
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
    ImeTooltipUpdate("")
    ImeSetIconState(mode)
    return
}

ImeModeIsChinese()
{
    global ime_mode_language
    return ime_mode_language == "cn" || ime_mode_language == "tw"
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