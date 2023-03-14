;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; Enter 上屏文字
Enter::
NumpadEnter::
    PutCandidateCharacter(ime_input_candidate)
    ime_input_candidate.SetSelectIndex(1)
    ime_input_candidate.Initialize(ime_input_string)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

]::
    PutCharacterWordByWord(ime_input_candidate.GetSelectIndex(), 0)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

[::
    PutCharacterWordByWord(ime_input_candidate.GetSelectIndex(), 1)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; Tab: Show more select items
Tab::
    if( ImeIsSelectMenuOpen() ){
        if( !ImeIsSelectMenuMore() ) {
            ImeOpenSelectMenu(true, true)
        } else {
            ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
        }
    } else {
        ImeOpenSelectMenu(true, false)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

+Tab::
    if( ImeIsSelectMenuOpen() ){
        if( !ImeIsSelectMenuMore() ){
            ImeOpenSelectMenu(false)
        }
        else { 
            ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
            if( GetSelectMenuColumn() >= ime_input_candidate.GetSelectIndex() ){
                ImeOpenSelectMenu(true, false)
            }
        }
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
    }
return

; BackSpace 删除光标前面的空格
BackSpace::
    if( ime_input_caret_pos != 0 ) {
        tooltip_debug[1] := ""
        tooltip_debug[5] := ""
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ime_input_candidate.Initialize(ime_input_string)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
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
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

,::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
    } else {
        ime_input_candidate.OffsetSelectIndex(-1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

.::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
    } else {
        ime_input_candidate.OffsetSelectIndex(+1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; 左右键移动光标
Left::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
    } else {
        ime_input_caret_pos -= 1
        if( ime_input_caret_pos < 0 ){
            ime_input_caret_pos := StrLen(ime_input_string)
        }
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

Right::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
    } else {
        ime_input_caret_pos += 1
        if( ime_input_caret_pos > StrLen(ime_input_string) ){
            ime_input_caret_pos := 0
        }
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; Shift + 左右键移动光标，不论是否打开候选框
+Left::
    ime_input_caret_pos -= 1
    if( ime_input_caret_pos < 0 ){
        ime_input_caret_pos := StrLen(ime_input_string)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

+Right::
    ime_input_caret_pos += 1
    if( ime_input_caret_pos > StrLen(ime_input_string) ){
        ime_input_caret_pos := 0
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; 上下选择
Up::
    if( ImeIsSelectMenuOpen() ) {
        ime_input_candidate.OffsetSelectIndex(-1)
    } else {
        if( ime_input_candidate.GetSelectIndex() >= 4 ) {
            ime_input_candidate.SetSelectIndex(1)
        } else {
            ime_input_candidate.OffsetSelectIndex(+1)
        }
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
    if( !ImeIsSelectMenuOpen() ) {
        ImeOpenSelectMenu(true, false)
    } else {
        ime_input_candidate.OffsetSelectIndex(+1)
    }
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
return

; 更新候选框位置
~WheelUp::
~WheelDown::
~LButton up::
    SetTimer, ImeTooltipUpdateTimer, -10
return

ImeTooltipUpdateTimer:
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate, true)
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