SetImeModeEn:
ime_mode_language := "en"
ImeUpdateIconState()
return

SetImeModeCn:
ime_mode_language := "cn"
ImeUpdateIconState()
return

;*******************************************************************************
; 全局变量
ImeInitialize:
ime_input_string := ""      ; 輸入字符
ime_mode_language := "cn"    ; "cn", "en", "tw"
ime_caret_pos := 0          ; 光标位置
ime_screeen_caret := ""     ; 输入法提示框光标位置
ime_select_index := 1       ; 选定的候选词，从 1 开始
ime_max_select_cnt := 9     ; 最大候选词个数
ime_candidate_sentences := [] ; 候选句子
ime_open_select_menu := 0   ; 是否打开选字窗口

ime_is_active_system_menu := 0  ; 是否打开菜单
ime_active_window_class := ""   ; 禁用 IME 的窗口是否被激活
ime_opt_pause_window_name_list  := ["Windows.UI.Core.CoreWindow"] ; 禁用 IME 的窗口列表


tooltip_font_size := 13
tooltip_font_family := "Microsoft YaHei Mono" ;"Ubuntu Mono derivative Powerline"
tooltip_font_bold := false

symbol_ctrl_start_hotkey := {"^``":"``", "^+``":"～", "^+1":"！", "^+2":"＠", "^+3":"#", "^+4":"$", "^+5":"％"
, "^+6":"……", "^+7":"＆", "^+8":"＊", "^+9":"「", "^+0":"」", "^-":"－", "^+-":"——", "^=":"＝", "^+=":"＋"
, "^[":"【", "^]":"】", "^+[":"（", "^+]":"）", "^\":"、", "^;":"；", "^+;": "：", "^'":"＇", "^+'":"＂"
, "^+,":"《","^+.":"》", "^,":"，", "^.":"。", "^+/":"？" }

; 注册 tooltip 样式
ToolTip(1, "", "Q1 B" tooltip_background_color " T"  tooltip_text_color " S" tooltip_font_size, tooltip_font_family, tooltip_font_bold)
Gosub, ImeRegisterHotkey
ImeUpdateIconState()

DllCall("SetWinEventHook", "UInt", 0x06, "UInt", 0x07, "Ptr", 0, "Ptr", RegisterCallback("EventProcHook"), "UInt", 0, "UInt", 0, "UInt", 0)
PinyinInit()
return

EventProcHook(phook, msg, hwnd)
{
    global ime_active_window_class
    global ime_is_active_system_menu

    if (A_IsSuspended)
        return
    Switch msg
    {
    case 0x03:                  ; EVENT_SYSTEM_FOREGROUND
        WinGetClass, win_class, ahk_id %hwnd%
        ime_active_window_class := win_class
        ImeUpdateIconState()
    case 0x06:                  ; EVENT_SYSTEM_MENUPOPUPSTART
        ime_is_active_system_menu := 1
        ImeUpdateIconState()
    case 0x07:                  ; EVENT_SYSTEM_MENUPOPUPEND
        ime_is_active_system_menu := 0
        ImeUpdateIconState()
    }
    return
}

;*******************************************************************************
; 注册按键
ImeRegisterHotkey:
; 当处于中文模式下
ime_is_waiting_input_fn := Func("ImeIsWaitingInput").Bind()
Hotkey if, % ime_is_waiting_input_fn
; 注册符号
for key, char in symbol_ctrl_start_hotkey
{
    func := Func("ImeInputChar").Bind(char, -1, 1)
    Hotkey, %key%, %func%
}
; 注册 a-z
loop 26
{
    func := Func("ImeInputChar").Bind(Chr(96+A_Index))
    Hotkey, % Chr(96+A_Index), %func%
    ; 当输入大写字母后关闭输入法
    Hotkey, % "~+" Chr(96+A_Index), TrySetImeModeEn
}
; 注册空格，用于分词
func := Func("ImeInputChar").Bind(" ", -1, 1)
Hotkey, Space, %func%
Hotkey, if,

; 当有输入字符时
Hotkey, if, ime_input_string
; 注册数字 0-9
loop 10 {
    func := Func("ImeInputNumber").Bind(A_Index-1)
    Hotkey, % A_Index-1, %func%
    Hotkey, % "Numpad" A_Index-1, %func%
}
; 数字 0-9 作为上屏用
; loop 10 {
;     key := "^" A_Index-1
;     Hotkey, % key, SelectAndPut
; }
Hotkey, if,
return

;*******************************************************************************
ImeIsPauseWindowActive()
{
    ; 菜单打开时，暂停 IME
    global ime_is_active_system_menu
    if( ime_is_active_system_menu ) {
        return 1
    }
    ; 当前激活的窗口的 class 在禁用列表中，暂停 IME
    global ime_active_window_class
    global ime_opt_pause_window_name_list
    for index, name in ime_opt_pause_window_name_list {
        if( name == ime_active_window_class ) {
            return 1
        }
    }
    return 0
}

ImeIsWaitingInput()
{
    global ime_mode_language
    return ime_mode_language == "cn" && !ImeIsPauseWindowActive()
}

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
    Gosub, ImeUpdateTooltip
}

ImeInputNumber(key) {
    global ime_open_select_menu

    ; 选择相应的编号并上屏
    if( ime_open_select_menu ) {
        PutCharacterByIndex(key)
        Gosub, CloseSelectMenu
        Gosub, ImeUpdateTooltip
    }
    else {
        ImeInputChar(key)
    }
}

; 更新提示
ImeUpdateTooltip:
if(ime_input_string){
    if (!ime_screeen_caret) {
        ime_screeen_caret := GetCaretPos()
    }
    tooltip_string := SubStr(ime_input_string, 1, ime_caret_pos) "|" SubStr(ime_input_string, ime_caret_pos+1)
    ; ToolTip, % ime_input_string "`n" tooltip_string "`n" ime_caret_pos

    if (last_ime_input != ime_input_string) {
        last_ime_input := ime_input_string
        ime_candidate_sentences := PinyinGetSentences(ime_input_string)
    }

    ime_select_tip := ""
    if( ime_open_select_menu ) {
        Loop % Min(ime_candidate_sentences.Length(), ime_max_select_cnt) {
            tvar := A_Index

            Index := ime_for_select_obj.Push(str)
            ime_select_tip .= "`n"
            if ( ime_select_index == A_Index ) {
                ime_select_tip .= "> "
            } else {
                ime_select_tip .= A_Index "."
            }
            ime_select_tip .= ime_candidate_sentences[A_Index, 2] . " " . ime_candidate_sentences[A_Index, 1] 
        }
    } else {
        ime_select_tip .= ime_candidate_sentences[ime_select_index, 2]
    }
    debug_tip := "`n----------------`n" ime_candidate_sentences.Length() "`n" ime_select_index
    ; ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_caret_pos "`n" ime_candidate_sentences.Length(), "x" ime_screeen_caret.x " y" ime_screeen_caret.Y+ime_screeen_caret.H)
    ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_select_tip debug_tip, "x" ime_screeen_caret.x " y" ime_screeen_caret.Y+ime_screeen_caret.H)
}else{
    ToolTip(1, "")
}
return

PutCharacterByIndex(select_index)
{
    global ime_candidate_sentences
    global ime_input_string
    string := ime_candidate_sentences[select_index,2]
    occupied_characters := ime_candidate_sentences[select_index,1]
    ime_input_string := SubStr(ime_input_string, StrLen(occupied_characters)+1)
    ; MsgBox, % StrLen(occupied_characters) "`n" ime_input_string
    PutCharacter( string )
    if( !ime_input_string ) {
        Gosub, ImeClearInputString
    }
}

;*******************************************************************************
; 当有输入字符时
#if ime_input_string

; 清除输入字符
ImeClearInputString:
ime_input_string := ""
ime_caret_pos := 0
ime_select_index := 1
ime_open_select_menu := 0
return

OpenSelectMenu:
ime_open_select_menu := 1
ime_select_index := 1
return

CloseSelectMenu:
ime_open_select_menu := 0
ime_select_index := 1
return

; Enter 上屏文字
Enter::
NumpadEnter::
PutCharacterByIndex(ime_select_index)
Gosub, CloseSelectMenu
Gosub, ImeUpdateTooltip
return

; BackSpace 删除光标前面的空格
BackSpace::
if( ime_caret_pos != 0 ) {
    ime_input_string := SubStr(ime_input_string, 1, ime_caret_pos-1) . SubStr(ime_input_string, ime_caret_pos+1)
    ime_caret_pos := ime_caret_pos-1
    Gosub, ImeUpdateTooltip
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
Gosub, ImeUpdateTooltip
return

; 左右键移动光标
Left::
ime_caret_pos := Max(0, ime_caret_pos-1)
Gosub, ImeUpdateTooltip
return

Right::
ime_caret_pos := Min(StrLen(ime_input_string), ime_caret_pos+1)
Gosub, ImeUpdateTooltip
return

; 上下选择
Up::
ime_select_index := Max(1, ime_select_index - 1)
Gosub, ImeUpdateTooltip
return

; 如果没有展开候选框则展开之，否则调整候选框的选项
Down::
if( !ime_open_select_menu ) {
    Gosub, OpenSelectMenu
} else {
    ime_select_index := Min(ime_max_select_cnt, ime_candidate_sentences.Length(), ime_select_index + 1)
}
Gosub, ImeUpdateTooltip
return
#if

#if (ime_mode_language == "cn")
; LShift 以英文文字上屏
Shift::
TrySetImeModeEn:
if (ime_input_string) {
    PutCharacter(ime_input_string)
    Gosub, ImeClearInputString
    Gosub, ImeUpdateTooltip
}
Gosub, SetImeModeEn
Hotkey, LShift up, TrySetImeModeCn, On
return
#if

TrySetImeModeCn:
if ( ime_mode_language == "en" ) {
    Gosub, SetImeModeCn
    Hotkey, LShift up, TrySetImeModeCn, Off
}
return

;*******************************************************************************
; Win + Space 切换输入法
#Space::
ImeToggleSuspend:
Suspend
Gosub, ImeClearInputString
Gosub, ImeUpdateTooltip
Gosub, TrySetImeModeCn
ImeUpdateIconState()
return

ImeSuspend:
if( !A_IsSuspended ) {
    Gosub, ImeToggleSuspend
}
return

#!Space::
ExitApp,
return

ImeUpdateIconState()
{
    local
    static ime_opt_icon_path := "ime.icl"
    tooltip_option := "X2300 Y1200"
    if(A_IsSuspended || ImeIsPauseWindowActive()){
        ToolTip(4, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        if ( ime_mode_language == "en" ) {
            tooltip_option := tooltip_option . " Q1 B1e1e1e T4f4f4f"
            info_text := "英"
        } else {
            tooltip_option := tooltip_option . " Q1 Bff4f4f Tfefefe"
            info_text := "中"
        }
        ToolTip(4, info_text, tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
