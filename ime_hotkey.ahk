;*******************************************************************************
; In typing
#if ImeInputterHasAnyInput()
    ; Input char
    %::
    ?::
        ImeInputterProcessChar("?")
        ImeTooltipUpdate()
    return

    ; Enter 上屏文字
    Enter::
    NumpadEnter::
        if( ImeSelectorIsOpen() ){
            ImeSelectorClose()
        } else {
            if( ImeInputterIsInputDirty() ) {
                ImeInputterUpdateString("")
            } else {
                PutCandidateCharacter()
            }
        }
        ImeTooltipUpdate()
    return

    ]::
        PutCharacterWordByWord(ImeSelectorGetSelectIndex(), 0)
        ImeSelectorClose()
        ImeTooltipUpdate()
    return

    [::
        PutCharacterWordByWord(ImeSelectorGetSelectIndex(), 1)
        ImeSelectorClose()
        ImeTooltipUpdate()
    return

    ; Tab: Show more select items
    Tab::
        if( ImeSelectorIsOpen() ){
            if( !ImeSelectorShowMultiple() && ImeSelectorCanShowMultiple() ) {
                ImeSelectorOpen(true)
            } else {
                ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
            }
        } else {
            ImeSelectorOpen()
        }
        ImeTooltipUpdate()
    return

    +Tab::
        if( ImeSelectorIsOpen() ){
            if( ImeSelectorGetSelectIndex() == 1 ){
                ImeSelectorClose()
            }
            else {
                ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
                if( ImeSelectorGetColumn() >= ImeSelectorGetSelectIndex() ){
                    ImeSelectorOpen()
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
            ImeSelectorOpen(true)
            ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
        }
        ImeTooltipUpdate()
    return

    =::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOpen(true)
            ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
        }
        ImeTooltipUpdate()
    return

    ; 左右键移动光标
    Left::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOffsetSelectIndex(-ImeSelectorGetColumn())
        } else {
            ImeInputterCaretMoveByWord(-1)
        }
        ImeTooltipUpdate()
    return

    Right::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOffsetSelectIndex(+ImeSelectorGetColumn())
        } else {
            ImeInputterCaretMoveByWord(+1)
        }
        ImeTooltipUpdate()
    return

    ; Ctrl + Left/Right
    ; Move caret by a word
    ^Left::
        ImeInputterCaretMoveByWord(-1)
        ImeTooltipUpdate()
    return

    ^Right::
        ImeInputterCaretMoveByWord(+1)
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
            if( ImeInputterIsInputDirty() ) {
                ImeInputterUpdateString("")
            } else {
                if( ImeSelectorGetSelectIndex() >= 4 ) {
                    ImeSelectorSetSelectIndex(1)
                } else {
                    ImeSelectorOffsetSelectIndex(+1)
                }
            }
            ; We call it for `ImeSelectorFixupSelectIndex`
            ImeSelectorClose()
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
            ImeSelectorOpen()
        } else {
            ImeSelectorOffsetSelectIndex(+1)
        }
        ImeTooltipUpdate()
    return

    NumpadHome::
    Home::
        ImeInputterCaretMoveToHome(true)
        ImeTooltipUpdate()
    return

    NumpadEnd::
    End::
        ImeInputterCaretMoveToHome(false)
        ImeTooltipUpdate()
    return

    ; 更新候选框位置
    ~WheelUp::
    ~WheelDown::
    ~LButton up::
        Sleep, 10
        ImeTooltipUpdatePos()
    return
#if ; ImeInputterHasAnyInput()

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
        ImeInputterUpdateString("")
        ImeTooltipUpdate()
    return

    F7::
        ImeStateUpdateMode("tw")
        ImeInputterUpdateString("")
        ImeTooltipUpdate()
    return

    F8::
        ImeStateUpdateMode("jp")
        ImeInputterUpdateString("")
        ImeTooltipUpdate()
    return

    ; F12: exit
    F12::
        ExitApp,
    return
#if ; !ImeModeIsEnglish()

;*******************************************************************************
; Reload script, debug only
#if WinActive("AHK-Ime") && !ImeModeIsEnglish()
    ~^S::
        ToolTip, Reload %A_ScriptName%
        Sleep, 500
        Reload
    return
#if

;*******************************************************************************
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
