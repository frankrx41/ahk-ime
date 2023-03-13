;*******************************************************************************
; 输入相关的函数
; 输入标点符号
; 输入字符
; 输入音调
ImeInputChar(key, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_tooltip_pos
    global tooltip_debug

    tooltip_debug := []
    if (!ime_input_string ) {
        ime_tooltip_pos := 0
    }
    pos := pos != -1 ? pos : ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, pos) . key . SubStr(ime_input_string, pos+1)
    ime_input_caret_pos := pos + 1
    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(key)
        ImeClearInputString()
    }
    ImeUpdateCandidate(ime_input_string)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
}

ImeInputNumber(key)
{
    global ime_input_string
    global ime_input_caret_pos
    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        start_index := Floor((GetSelectWordIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
        PutCharacterByIndex(start_index + (key == 0 ? 10 : key))
        SetSelectWordIndex(1)
        ImeUpdateCandidate(ime_input_string)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
    }
    else {
        ImeInputChar(key)
    }
}

;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; Enter 上屏文字
Enter::
NumpadEnter::
    PutCharacterByIndex(GetSelectWordIndex())
    SetSelectWordIndex(1)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

]::
    PutCharacterWordByWord(GetSelectWordIndex(), 0)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

[::
    PutCharacterWordByWord(GetSelectWordIndex(), 1)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

; Tab: Show more select items
Tab::
    if( ImeIsSelectMenuOpen() ){
        if( !ImeIsSelectMenuMore() ) {
            ImeOpenSelectMenu(true, true)
        } else {
            OffsetSelectWordIndex(+GetSelectMenuColumn())
        }
    } else {
        ImeOpenSelectMenu(true, false)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

+Tab::
    if( ImeIsSelectMenuOpen() ){
        if( !ImeIsSelectMenuMore() ){
            ImeOpenSelectMenu(false)
        }
        else { 
            OffsetSelectWordIndex(-GetSelectMenuColumn())
            if( GetSelectMenuColumn() >= GetSelectWordIndex() ){
                ImeOpenSelectMenu(true, false)
            }
        }
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
    }
return

; BackSpace 删除光标前面的空格
BackSpace::
    if( ime_input_caret_pos != 0 ) {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeUpdateCandidate(ime_input_string)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
    }
return

; Esc
; 如果有展开候选框则关闭
; 否则删除所有输入的字符
Esc::
    if( ImeIsSelectMenuOpen() ) {
        if( ImeIsSelectMenuMore() ) {
            ImeOpenSelectMenu(true, false)
        } else {
            ImeOpenSelectMenu(false)
        }
    } else {
        ImeClearInputString()
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

,::
    if( ImeIsSelectMenuOpen() ){
        OffsetSelectWordIndex(-GetSelectMenuColumn())
    } else {
        OffsetSelectWordIndex(-1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

.::
    if( ImeIsSelectMenuOpen() ){
        OffsetSelectWordIndex(+GetSelectMenuColumn())
    } else {
        OffsetSelectWordIndex(+1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

; 左右键移动光标
Left::
    if( ImeIsSelectMenuOpen() ){
        OffsetSelectWordIndex(-GetSelectMenuColumn())
    } else {
        ime_input_caret_pos := Max(0, ime_input_caret_pos-1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

Right::
    if( ImeIsSelectMenuOpen() ){
        OffsetSelectWordIndex(+GetSelectMenuColumn())
    } else {
        ime_input_caret_pos := Min(StrLen(ime_input_string), ime_input_caret_pos+1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

; 上下选择
Up::
    if( ImeIsSelectMenuOpen() ) {
        OffsetSelectWordIndex(-1)
    } else {
        if( GetSelectWordIndex() >= 4 ) {
            SetSelectWordIndex(1)
        } else {
            OffsetSelectWordIndex(+1)
        }
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
    if( !ImeIsSelectMenuOpen() ) {
        ImeOpenSelectMenu(true, false)
    } else {
        OffsetSelectWordIndex(+1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

; 更新候选框位置
~WheelUp::
~WheelDown::
~LButton up::
    ime_tooltip_pos := 0
    SetTimer, ImeTooltipUpdateTimer, -10
return

ImeTooltipUpdateTimer:
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos)
return

#if ; ime_input_string

;*******************************************************************************
; Win + Space: toggle cn and en
#Space::
ImeToggleSuspend:
    Suspend
    ; 英文状态下恢复成中文
    if( A_ThisHotkey == "#Space" && A_IsSuspended && !ImeModeIsChinese() ){
        Gosub, ImeToggleSuspend
    }
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