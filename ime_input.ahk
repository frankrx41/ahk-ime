;*******************************************************************************
; 清除输入字符
ImeClearInputString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global tooltip_debug

    ime_input_string    := ""
    ime_input_caret_pos := 0
    ime_input_candidate := 0
    tooltip_debug := []
    SetSelectWordIndex(1)
    ImeOpenSelectMenu(false)
    return
}

;*******************************************************************************
; 切换成英文前以原始输入上屏文字
CallBackBeforeToggleEn()
{
    global ime_input_string

    if ( ime_input_string ) {
        PutCharacter(ime_input_string)
        ImeClearInputString()
    }
    return
}

PutCharacterByIndex(select_index)
{
    global ime_input_string
    global ime_input_candidate

    string := ImeGetCandidateWord(ime_input_candidate, select_index)
    occupied_characters := ImeGetCandidatePinyin(ime_input_candidate, select_index)
    ime_input_string := SubStr(ime_input_string, StrLen(occupied_characters)+1-StrLen(string)+1)
    ; MsgBox, % StrLen(occupied_characters) "`n" ime_input_string
    PutCharacter( string )
    if( !ime_input_string ) {
        ImeClearInputString()
    }
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    global ime_input_candidate
    string := ImeGetCandidateWord(ime_input_candidate, select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeClearInputString()
}

;*******************************************************************************
; 输入相关的函数
; 输入标点符号
; 输入字符
; 输入音调
ImeInputChar(key, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_input_candidate
    global tooltip_debug

    update_coord := false
    tooltip_debug := []
    if (!ime_input_string ) {
        update_coord := true
    }
    pos := pos != -1 ? pos : ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, pos) . key . SubStr(ime_input_string, pos+1)
    ime_input_caret_pos := pos + 1
    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(key)
        ImeClearInputString()
    }
    ime_input_candidate := ImeGetCandidate(ime_input_string)
    ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate, update_coord)
}

ImeInputNumber(key)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate

    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        start_index := Floor((GetSelectWordIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
        PutCharacterByIndex(start_index + (key == 0 ? 10 : key))
        SetSelectWordIndex(1)
        ime_input_candidate := ImeGetCandidate(ime_input_string)
        ImeTooltipUpdate(ime_input_string, ime_input_caret_pos, ime_input_candidate)
    }
    else {
        ImeInputChar(key)
    }
}
