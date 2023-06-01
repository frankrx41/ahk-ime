;*******************************************************************************
; Ime state
ImeStateInitialize()
{
    global ime_mode_language
    global ime_is_active_system_menu
    global ime_active_window_class
    global ime_opt_pause_window_name_list
    global ime_is_force_simple_spell
    global ime_debug_switch
    
    ime_mode_language           := "en"         ; "cn", "en", "tw", "jp"
    ime_is_active_system_menu   := 0            ; 是否打开菜单
    ime_active_window_class     := ""           ; 禁用 IME 的窗口是否被激活
    ime_opt_pause_window_name_list  := ["Windows.UI.Core.CoreWindow"] ; 禁用 IME 的窗口列表
    ime_is_force_simple_spell   := false
    ime_debug_switch            := 0            ; 0 hide 1 show tick only 2 show full

    DllCall("SetWinEventHook", "UInt", 0x03, "UInt", 0x07, "Ptr", 0, "Ptr", RegisterCallback("ImeStateEventProcHook"), "UInt", 0, "UInt", 0, "UInt", 0)
    ; Notice: if `ime_mode_language` same as here, state will not update
    ImeStateUpdateMode("cn")

    ; Update system tray
    Menu, Tray, Tip, % "AHK IME `n" GetVersionText()
}

ImeStateEventProcHook(phook, msg, hwnd)
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
        ImeStateRefresh()
        ImeTooltipUpdate()
    case 0x06:                  ; EVENT_SYSTEM_MENUPOPUPSTART
        ime_is_active_system_menu := 1
        ImeStateRefresh()
        ImeTooltipUpdate()
    case 0x07:                  ; EVENT_SYSTEM_MENUPOPUPEND
        ime_is_active_system_menu := 0
        ImeStateRefresh()
        ImeTooltipUpdate()
    }
    return
}

ImeStateRefresh()
{
    if( A_IsSuspended || ImeStatePauseWindowActive() )
    {
        ImeInputterClearAll()
        ImeSelectMenuClose()
        ImeIconSetMode("")
    }
    else
    {
        ImeStateUpdateMode(ImeModeGetLanguage())
    }
}

ImeStateUpdateMode(mode)
{
    local
    last_mode := ImeModeGetLanguage()
    if( mode != last_mode )
    {
        ImeModeSetLanguage(mode)
        if( mode != "en" ) {
            ImeHotkeyRegisterShift("en")
        } else {
            ImeHotkeyRegisterShift(last_mode)
        }
    }
    if( mode == "tw" )
    {
        PinyinTraditionalInitialize()
    }
    ImeIconSetMode(mode)
}

ImeStatePauseWindowActive()
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

ImeStateWaitingInput()
{
    return !ImeModeIsEnglish() && !ImeStatePauseWindowActive()
}

;*******************************************************************************
; Mode
ImeModeSetLanguage(mode)
{
    global ime_mode_language
    switch (mode) {
    case "cn", "en", "tw", "jp":    ime_mode_language := mode
    default:                        ime_mode_language := "en"
    }
}

ImeModeGetLanguage()
{
    global ime_mode_language
    return ime_mode_language
}

ImeModeIsEnglish()
{
    global ime_mode_language
    return ime_mode_language == "en"
}

ImeModeIsChinese()
{
    global ime_mode_language
    return ImeModeIsSimChinese() || ImeModeIsTraChinese()
}

ImeModeIsSimChinese()
{
    global ime_mode_language
    return ime_mode_language == "cn"
}

ImeModeIsTraChinese()
{
    global ime_mode_language
    return ime_mode_language == "tw"
}

ImeModeIsJapanese()
{
    global ime_mode_language
    return ime_mode_language == "jp"
}

;*******************************************************************************
; Simple spell
ImeSimpleSpellIsForce()
{
    global ime_is_force_simple_spell
    return ime_is_force_simple_spell
}

ImeSimpleSpellToggle()
{
    global ime_is_force_simple_spell
    ime_is_force_simple_spell := !ime_is_force_simple_spell
}

ImeSimpleSpellSetForce(force)
{
    global ime_is_force_simple_spell
    ime_is_force_simple_spell := force
}

;*******************************************************************************
; Debug
; 1
ImeDebugGet()
{
    global ime_debug_switch
    return ime_debug_switch
}

ImeDebugToggle()
{
    global ime_debug_switch
    ime_debug_switch += 1
    if( ime_debug_switch >= 3 ) {
        ime_debug_switch := 0
    }
}

;*******************************************************************************
; Icon
ImeIconSetMode(mode)
{
    local
    static ime_opt_icon_path := "data\ime.icl"
    tooltip_option := "X2300 Y1200"
    if( !mode ){
        ToolTip(4, "", "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        switch (mode) {
        case "en": info_text := "英", tooltip_option := tooltip_option . " Q1 B1e1e1e T4f4f4f"
        case "cn": info_text := "中", tooltip_option := tooltip_option . " Q1 Bff4f4f Tfefefe"
        case "tw": info_text := "漢", tooltip_option := tooltip_option . " Q1 B0033cc Tfefefe"
        case "jp": info_text := "日", tooltip_option := tooltip_option . " Q1 B339933 Tfefefe"
        }
        ToolTip(4, info_text, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
