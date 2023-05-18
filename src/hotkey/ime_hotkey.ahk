;*******************************************************************************
; In typing
#if ImeInputterHasAnyInput()
    ; Input char

    ; Fuzzy pinyin
    ?::
        ImeInputterProcessChar("?")
        ImeTooltipUpdate()
    return

    ; Auto complete
    NumpadMult::
    *::
        ImeSimpleSpellToggle()
        ImeInputterUpdateString("")
        ImeTooltipUpdate()
    return

    ; Simple spell
    NumpadAdd::
    +::
        ImeInputterProcessChar("+")
        ImeTooltipUpdate()
    return

    ; Verb
    !::
        ImeInputterProcessChar("!")
        ImeTooltipUpdate()
    return

    @::
        ImeInputterProcessChar("@")
        ImeTooltipUpdate()
    return

    ; Measure
    #::
        ImeInputterProcessChar("#")
        ImeTooltipUpdate()
    return

    $::
        ImeInputterProcessChar("$")
        ImeTooltipUpdate()
    return

    %::
        ImeInputterProcessChar("%")
        ImeTooltipUpdate()
    return

    ^::
        ImeInputterProcessChar("^")
        ImeTooltipUpdate()
    return

    &::
        ImeInputterProcessChar("&")
        ImeTooltipUpdate()
    return

    ; Enter send string
    Enter::
    NumpadEnter::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectMenuClose()
            ImeSelectorApplyCaretSelectIndex(true)
        } else {
            if( ImeInputterIsInputDirty() ) {
                ImeInputterUpdateString("")
            } else {
                ImeOutputterPutSelect(false)
            }
        }
        ImeTooltipUpdate()
    return

    ]::
        ImeOutputterPutSelect(false, -1)
        ImeTooltipUpdate()
    return

    [::
        ImeOutputterPutSelect(false, 1)
        ImeTooltipUpdate()
    return

    ; Tab: Show more select items
    Tab::
        if( ImeSelectMenuIsOpen() ){
            if( !ImeSelectMenuIsMultiple() && ImeSelectMenuCanShowMultiple() ) {
                ImeSelectMenuOpen(true)
            } else {
                ImeSelectorOffsetCaretSelectIndex(+ImeSelectMenuGetColumn())
            }
        } else {
            if( ImeSelectorGetCaretSelectIndex() == 0 )
            {
                ImeSelectorSetCaretSelectIndex(1)
            }
            ImeSelectMenuOpen()
        }
        ImeTooltipUpdate()
    return

    +Tab::
        if( ImeSelectMenuIsOpen() ){
            if( ImeSelectorGetCaretSelectIndex() == 1 ){
                ImeSelectMenuClose()
                ImeSelectorApplyCaretSelectIndex(true)
            }
            else {
                ImeSelectorOffsetCaretSelectIndex(-ImeSelectMenuGetColumn())
                if( ImeSelectMenuGetColumn() >= ImeSelectorGetCaretSelectIndex() ){
                    ImeSelectMenuOpen()
                }
            }
            ImeTooltipUpdate()
        }
    return

    ; Delete before and after char
    Delete::
        ImeInputterDeleteCharAtCaret(false)
        ImeTooltipUpdate()
    return

    BackSpace::
        ImeInputterDeleteCharAtCaret(true)
        ImeTooltipUpdate()
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
        if( ImeSelectMenuIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectMenuGetColumn())
        } else {
            ImeSelectorOffsetCaretSelectIndex(-1)
            ImeSelectorApplyCaretSelectIndex(true)
        }
        ImeTooltipUpdate()
    return

    .::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectMenuGetColumn())
        } else {
            ImeSelectorOffsetCaretSelectIndex(+1)
            ImeSelectorApplyCaretSelectIndex(true)
        }
        ImeTooltipUpdate()
    return

    -::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectMenuOpen(true)
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectMenuGetColumn())
        } else {
            ImeInputterProcessChar("-")
        }
        ImeTooltipUpdate()
    return

    =::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectMenuOpen(true)
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectMenuGetColumn())
        }
        ImeTooltipUpdate()
    return

    ; 左右键移动光标
    Left::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(-ImeSelectMenuGetColumn())
        } else {
            ImeInputterCaretMoveByWord(-1)
        }
        ImeTooltipUpdate()
    return

    Right::
        if( ImeSelectMenuIsOpen() ){
            ImeSelectorOffsetCaretSelectIndex(+ImeSelectMenuGetColumn())
        } else {
            ImeInputterCaretMoveSmartRight()
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
        if( ImeSelectMenuIsOpen() ) {
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
                ImeSelectorApplyCaretSelectIndex(true, false)
            }
        }
        ImeTooltipUpdate()
    return

    ; 如果没有展开候选框则展开之，否则调整候选框的选项
    Down::
        if( ImeSelectMenuIsOpen() ) {
            ImeSelectorOffsetCaretSelectIndex(+1)
        } else {
            ImeSelectorStoreSelectIndexBeforeMenuOpen()
            if( ImeSelectorGetCaretSelectIndex() == 0 )
            {
                ImeSelectorSetCaretSelectIndex(1)
            }
            ImeSelectMenuOpen()
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
        ImeTooltipUpdate()
    return
#if ; ImeInputterHasAnyInput()

;*******************************************************************************
; Is not English mode
#if !ImeModeIsEnglish()
    ; Create word gui
    !`::
        WordCreatorUI(GetSelectText())
    return

    ; Ctrl + Shift + F5: reload
    ^+F5::
        ScriptRestart()
    return

    ^F5::
        ToolTip, Clear history
        Sleep, 500
        ToolTip,
        TranslatorHistoryClear()
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

    F12::
        ImeDebugToggle()
        ImeInputterUpdateString("")
        ImeTooltipUpdate()
    return

    ; Ctrl + F12: exit
    ^F12::
        ExitApp,
    return
#if ; !ImeModeIsEnglish()

;*******************************************************************************
; Reload script, debug only
#if WinActive("AHK-Ime") && !ImeModeIsEnglish()
    ~^S::
        ScriptRestart()
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
    ImeInputterClearString()
    ImeStateRefresh()
    ImeTooltipUpdate()
return
