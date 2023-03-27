;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; Enter 上屏文字
Enter::
NumpadEnter::
    PutCandidateCharacter(ime_input_candidate)
    ImeTooltipUpdate()
return

]::
    PutCharacterWordByWord(ime_input_candidate.GetSelectIndex(), 0)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate()
return

[::
    PutCharacterWordByWord(ime_input_candidate.GetSelectIndex(), 1)
    ImeOpenSelectMenu(false)
    ImeTooltipUpdate()
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
    ImeTooltipUpdate()
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
        ImeTooltipUpdate()
    }
return

; BackSpace 删除光标前面的空格
BackSpace::
    HotkeyOnBackSpace()
return

; Ctrl + Backspace
; Delete word before this
^BackSpace::
    ImeClearSplitedInputBefore(ime_input_caret_pos)
    ImeTooltipUpdate()
return

; Esc
; 如果有展开候选框则关闭
; 否则删除所有输入的字符
Esc::
    HotkeyOnEsc()
return

,::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
    } else {
        ime_input_candidate.OffsetSelectIndex(-1)
    }
    ImeTooltipUpdate()
return

.::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
    } else {
        ime_input_candidate.OffsetSelectIndex(+1)
    }
    ImeTooltipUpdate()
return

-::
    if( ImeIsSelectMenuOpen() ){
        ImeOpenSelectMenu(true, true)
        ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
    }
    ImeTooltipUpdate()
return

=::
    if( ImeIsSelectMenuOpen() ){
        ImeOpenSelectMenu(true, true)
        ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
    }
    ImeTooltipUpdate()
return

; 左右键移动光标
Left::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(-GetSelectMenuColumn())
    } else {
        ImeInputCaretMove(-1, true)
    }
    ImeTooltipUpdate()
return

Right::
    if( ImeIsSelectMenuOpen() ){
        ime_input_candidate.OffsetSelectIndex(+GetSelectMenuColumn())
    } else {
        ImeInputCaretMove(+1, true)
    }
    ImeTooltipUpdate()
return

; Ctrl + Left/Right
; Move caret by a word
^Left::
    ImeInputCaretMove(-1, true)
    ImeTooltipUpdate()
return

^Right::
    ImeInputCaretMove(+1, true)
    ImeTooltipUpdate()
return

; Shift + 左右键移动光标，不论是否打开候选框
+Left::
    ImeInputCaretMove(-1)
    ImeTooltipUpdate()
return

+Right::
    ImeInputCaretMove(+1)
    ImeTooltipUpdate()
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
    ImeTooltipUpdate()
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
    if( !ImeIsSelectMenuOpen() ) {
        ImeOpenSelectMenu(true, false)
    } else {
        ime_input_candidate.OffsetSelectIndex(+1)
    }
    ImeTooltipUpdate()
return

; 更新候选框位置
~WheelUp::
~WheelDown::
~LButton up::
    Sleep, 10
    ImeTooltipUpdatePos()
return

#if ; ime_input_string

!`::
    WordCreateGui(GetSelectText())
    PinyinHistoryClear()
return

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
