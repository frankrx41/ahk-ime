;*******************************************************************************
; Ime state
ImeStateInitialize()
{
    global ime_is_active_system_menu
    global ime_active_window_class
    global ime_opt_pause_window_name_list
    
    ime_is_active_system_menu   := 0            ; 是否打开菜单
    ime_active_window_class     := ""           ; 禁用 IME 的窗口是否被激活
    ime_opt_pause_window_name_list  := ["Windows.UI.Core.CoreWindow"] ; 禁用 IME 的窗口列表

    ImeLanguageInitialize()
    ImeSimpleSpellInitialize()
    ImeDebugInitialize()

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
        ImeStateUpdateMode(ImeLanguageGet())
    }
}

ImeStateUpdateMode(mode)
{
    local
    last_mode := ImeLanguageGet()
    if( mode != last_mode )
    {
        ImeLanguageSet(mode)
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
    return !ImeLanguageIsEnglish() && !ImeStatePauseWindowActive()
}
