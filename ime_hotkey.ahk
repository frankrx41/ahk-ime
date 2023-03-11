;*******************************************************************************
; 输入相关的函数
; 输入标点符号
; 输入字符
; 输入音调
ImeInputChar(key, pos := -1, try_puts := 0)
{
    global ime_caret_pos
    global ime_input_string
    global ime_screeen_caret

    if (!ime_input_string ) {
        ime_screeen_caret := 0
    }
    pos := pos != -1 ? pos : ime_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, pos) . key . SubStr(ime_input_string, pos+1)
    ime_caret_pos := pos + 1
    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(key)
        Gosub, ImeClearInputString
    }
    ImeTooltipUpdate()
}

ImeInputNumber(key) {
    global ime_open_select_menu

    ; 选择相应的编号并上屏
    if( ime_open_select_menu ) {
        PutCharacterByIndex(key)
        Gosub, CloseSelectMenu
        ImeTooltipUpdate()
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
PutCharacterByIndex(ime_select_index)
Gosub, CloseSelectMenu
ImeTooltipUpdate()
return

; BackSpace 删除光标前面的空格
BackSpace::
if( ime_caret_pos != 0 ) {
    ime_input_string := SubStr(ime_input_string, 1, ime_caret_pos-1) . SubStr(ime_input_string, ime_caret_pos+1)
    ime_caret_pos := ime_caret_pos-1
    ImeTooltipUpdate()
}
return


; Esc
; 如果有展开候选框则关闭
; 否则删除所有输入的字符
Esc::
if( ime_open_select_menu ) {
    Gosub, CloseSelectMenu
} else {
    Gosub, ImeClearInputString
}
ImeTooltipUpdate()
return

; 左右键移动光标
Left::
ime_caret_pos := Max(0, ime_caret_pos-1)
ImeTooltipUpdate()
return

Right::
ime_caret_pos := Min(StrLen(ime_input_string), ime_caret_pos+1)
ImeTooltipUpdate()
return

; 上下选择
Up::
ime_select_index := Max(1, ime_select_index - 1)
ImeTooltipUpdate()
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
if( !ime_open_select_menu ) {
    Gosub, OpenSelectMenu
} else {
    ime_select_index := Min(ime_max_select_cnt, ime_candidate_sentences.Length(), ime_select_index + 1)
}
ImeTooltipUpdate()
return

#if

#if ImeModeIsChinese()
; LShift 以英文文字上屏
Shift::
TrySetImeModeEn:
if (ime_input_string) {
    PutCharacter(ime_input_string)
    Gosub, ImeClearInputString
    ImeTooltipUpdate()
}
ImeSetMode("en")
ImeUpdateIconState()
Hotkey, LShift up, TrySetImeModeCn, On
return
#if

;*******************************************************************************
; Win + Space: toggle cn and en
#Space::
ImeToggleSuspend:
Suspend
Gosub, ImeClearInputString
ImeTooltipUpdate()
Gosub, TrySetImeModeCn
ImeUpdateIconState()
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