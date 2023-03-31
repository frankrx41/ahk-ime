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
        PutCharacterWordByWord(ImeSelectorGetCaretSelectIndex(), 0)
        ImeSelectorClose()
        ImeTooltipUpdate()
    return

    [::
        PutCharacterWordByWord(ImeSelectorGetCaretSelectIndex(), 1)
        ImeSelectorClose()
        ImeTooltipUpdate()
    return

    ; Tab: Show more select items
    Tab::
        if( ImeSelectorIsOpen() ){
            if( !ImeSelectorShowMultiple() && ImeSelectorCanShowMultiple() ) {
                ImeSelectorOpen(true)
            } else {
                ImeSelectorOffsetCaretSelectIndex(+ImeSelectorGetColumn())
            }
        } else {
            ImeSelectorOpen()
        }
        ImeTooltipUpdate()
    return

    +Tab::
        if( ImeSelectorIsOpen() ){
            if( ImeSelectorGetCaretSelectIndex() == 1 ){
                ImeSelectorClose()
            }
            else {
                ImeSelectorOffsetCaretSelectIndex(-ImeSelectorGetColumn())
                if( ImeSelectorGetColumn() >= ImeSelectorGetCaretSelectIndex() ){
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
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectorGetColumn())
        } else {
            ImeSelectorOffsetCaretSelectIndex(-1)
        }
        ImeTooltipUpdate()
    return

    .::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectorGetColumn())
        } else {
            ImeSelectorOffsetCaretSelectIndex(+1)
        }
        ImeTooltipUpdate()
    return

    -::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOpen(true)
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectorGetColumn())
        }
        ImeTooltipUpdate()
    return

    =::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOpen(true)
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectorGetColumn())
        }
        ImeTooltipUpdate()
    return

    ; 左右键移动光标
    Left::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectorGetColumn())
        } else {
            ImeInputterCaretMoveByWord(-1)
        }
        ImeTooltipUpdate()
    return

    Right::
        if( ImeSelectorIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectorGetColumn())
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
            ImeSelectorOffsetCaretSelectIndex(-1)
        } else {
            if( ImeInputterIsInputDirty() ) {
                ImeInputterUpdateString("")
            } else {
                if( ImeSelectorGetCaretSelectIndex() >= 4 ) {
                    ImeSelectorSetCaretSelectIndex(1)
                } else {
                    ImeSelectorOffsetCaretSelectIndex(+1)
                }
                ; We call it for `ImeSelectorFixupSelectIndex`
                ImeSelectorClose()
            }
        }
        ImeTooltipUpdate()
    return

    ; 如果没有展开候选框则展开之，否则调整候选框的选项
    Down::
        if( ImeSelectorIsOpen() ) {
            ImeSelectorOffsetCaretSelectIndex(+1)
        } else {
            ImeSelectorOpen()
            if( ImeSelectorGetCaretSelectIndex() == 0 )
            {
                ImeSelectorSetCaretSelectIndex(1)
            }
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
