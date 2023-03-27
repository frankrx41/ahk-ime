;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; Enter 上屏文字
Enter::
NumpadEnter::
    PutCandidateCharacter()
    ImeTooltipUpdate()
return

]::
    PutCharacterWordByWord(ImeSelectorGetSelectIndex(), 0)
    ImeSelectorOpen(false)
    ImeTooltipUpdate()
return

[::
    PutCharacterWordByWord(ImeSelectorGetSelectIndex(), 1)
    ImeSelectorOpen(false)
    ImeTooltipUpdate()
return

; Tab: Show more select items
Tab::
    if( ImeSelectorIsOpen() ){
        if( !ImeSelectorShowMultiple() ) {
            ImeSelectorOpen(true, true)
        } else {
            ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
        }
    } else {
        ImeSelectorOpen(true, false)
    }
    ImeTooltipUpdate()
return

+Tab::
    if( ImeSelectorIsOpen() ){
        if( !ImeSelectorShowMultiple() ){
            ImeSelectorOpen(false)
        }
        else { 
            ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
            if( ImeSelectorGetColumn() >= ImeSelectorGetSelectIndex() ){
                ImeSelectorOpen(true, false)
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
    ImeInputterClearPrevSplitted(ime_input_caret_pos)
    ImeTooltipUpdate()
return

; Esc
; 如果有展开候选框则关闭
; 否则删除所有输入的字符
Esc::
    HotkeyOnEsc()
return

,::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
    } else {
        ImeSelectorOffsetSelectIndex(-1)
    }
    ImeTooltipUpdate()
return

.::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
    } else {
        ImeSelectorOffsetSelectIndex(+1)
    }
    ImeTooltipUpdate()
return

-::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOpen(true, true)
        ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
    }
    ImeTooltipUpdate()
return

=::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOpen(true, true)
        ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
    }
    ImeTooltipUpdate()
return

; 左右键移动光标
Left::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
    } else {
        ImeInputterCaretMove(-1, true)
    }
    ImeTooltipUpdate()
return

Right::
    if( ImeSelectorIsOpen() ){
        ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
    } else {
        ImeInputterCaretMove(+1, true)
    }
    ImeTooltipUpdate()
return

; Ctrl + Left/Right
; Move caret by a word
^Left::
    ImeInputterCaretMove(-1, true)
    ImeTooltipUpdate()
return

^Right::
    ImeInputterCaretMove(+1, true)
    ImeTooltipUpdate()
return

; Shift + 左右键移动光标，不论是否打开候选框
+Left::
    ImeInputterCaretMove(-1)
    ImeTooltipUpdate()
return

+Right::
    ImeInputterCaretMove(+1)
    ImeTooltipUpdate()
return

; 上下选择
Up::
    if( ImeSelectorIsOpen() ) {
        ImeSelectorOffsetSelectIndex(-1)
    } else {
        if( ImeSelectorGetSelectIndex() >= 4 ) {
            ImeSelectorSetSelectIndex(1)
        } else {
            ImeSelectorOffsetSelectIndex(+1)
        }
    }
    ImeTooltipUpdate()
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
    if( !ImeSelectorIsOpen() ) {
        ImeSelectorOpen(true, false)
    } else {
        ImeSelectorOffsetSelectIndex(+1)
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
    WordCreatorUI(GetSelectText())
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
    ImeStateUpdateMode("cn")
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
