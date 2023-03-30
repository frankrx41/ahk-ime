;*******************************************************************************
; 当有输入字符时
#if ime_input_string

    ; Enter 上屏文字
    Enter::
    NumpadEnter::
        if( ImeSelectorIsOpen() ){
            ImeSelectorFixupSelectIndex()
            ImeSelectorOpen(false)
        } else {
            if( !ImeInputterUpdateString(ime_input_string) )
            {
                PutCandidateCharacter()
            }
        }
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
        ImeInputterClearPrevSplitted()
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
            if( !ImeInputterUpdateString(ime_input_string) )
            {
                if( ImeSelectorGetSelectIndex() >= 4 ) {
                    ImeSelectorResetSelectIndex()
                } else {
                    ImeSelectorOffsetSelectIndex(+1)
                }
            }
            ImeSelectorFixupSelectIndex()
        }
        ImeTooltipUpdate()
    return

    ; 如果没有展开候选框则展开之，否则调整候选框的选项
    Down::
        if( !ImeSelectorIsOpen() ) {
            if( ImeSelectorGetSelectIndex() == 0 )
            {
                ImeSelectorSetSelectIndex(1)
            }
            ImeSelectorOpen(true, false)
        } else {
            ImeSelectorOffsetSelectIndex(+1)
        }
        ImeTooltipUpdate()
    return

    NumpadHome::
    Home::
        ImeInputterCaretMoveHome(true)
        ImeTooltipUpdate()
    return

    NumpadEnd::
    End::
        ImeInputterCaretMoveHome(false)
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

;*******************************************************************************
; Is not English mode
#if !ImeModeIsEnglish()
    ; Create word gui
    !`::
        WordCreatorUI(GetSelectText())
        PinyinHistoryClear()
    return

    ; F5: reload
    F5::
        ToolTip, Reload %A_ScriptName%
        Sleep, 500
        Reload
    return

    F6::
        ImeStateUpdateMode("cn")
    return

    F7::
        ImeStateUpdateMode("tw")
    return

    F8::
        ImeStateUpdateMode("jp")
    return

    ; F12: exit
    F12::
        ExitApp,
    return
#if

; Win + Space: toggle cn and en
#Space::
ImeToggleSuspend:
    Suspend
    if( A_ThisHotkey == "#Space" && !A_IsSuspended && ImeModeIsEnglish() ){
        ImeHotkeyShiftDown()
    }
    ImeStateRefresh()
    ImeTooltipUpdate("")
return
