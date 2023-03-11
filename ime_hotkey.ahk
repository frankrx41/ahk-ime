;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; Enter 上屏文字
Enter::
NumpadEnter::
    PutCharacterByIndex(ime_select_index)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate()
return

; BackSpace 删除光标前面的空格
BackSpace::
    if( ime_input_caret_pos != 0 ) {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeTooltipUpdate()
    }
return

; Esc
; 如果有展开候选框则关闭
; 否则删除所有输入的字符
Esc::
    if( ImeIsSelectMenuOpen() ) {
        ImeOpenSelectMenu(false)
    } else {
        ImeClearInputString()
    }
    ImeTooltipUpdate()
return

; 左右键移动光标
Left::
    ime_input_caret_pos := Max(0, ime_input_caret_pos-1)
    ImeTooltipUpdate()
return

Right::
    ime_input_caret_pos := Min(StrLen(ime_input_string), ime_input_caret_pos+1)
    ImeTooltipUpdate()
return

; 上下选择
Up::
    UpdateSelectWordIndex(-1)
    ImeTooltipUpdate()
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
    if( !ImeIsSelectMenuOpen() ) {
        ImeOpenSelectMenu(true)
    } else {
        UpdateSelectWordIndex(+1)
    }
    ImeTooltipUpdate()
return

; 更新候选框位置
~WheelUp::
~WheelDown::
~LButton up::
    ime_tooltip_pos := 0
    SetTimer, ImeTooltipUpdateTimer, -10
return

ImeTooltipUpdateTimer:
    ImeTooltipUpdate()
return

#if ; ime_input_string

;*******************************************************************************
; Win + Space: toggle cn and en
#Space::
    Suspend
    ImeUpdateActiveState("cn")
return

; Win + Alt + Space: reload
#!Space::
    ToolTip, Reload %A_ScriptName%
    Sleep, 500
    Reload
return

; Ctrl + Shift + F12: exit
^+F12::
    ExitApp,
return