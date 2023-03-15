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
    tooltip_debug := []
    ime_input_candidate.SetSelectIndex(1)
    ImeOpenSelectMenu(false)
    ImeClearAuxiliaryCode()
    return
}

ImeClearAuxiliaryCode()
{
    global ime_auxiliary_code
    ime_auxiliary_code := ""
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

PutCandidateCharacter(candidate)
{
    global ime_input_string
    global ime_input_caret_pos

    send_word := candidate.GetSendSelectWord()
    PutCharacter( send_word )

    before_input_string := ime_input_string
    ime_input_string := candidate.GetRemainString()
    ime_input_caret_pos -= StrLen(before_input_string) - StrLen(ime_input_string)

    if( !ime_input_string )
    {
        ImeClearInputString()
    }
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    global ime_input_candidate
    string := ime_input_candidate.GetWord(select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeClearInputString()
}

;*******************************************************************************
; 输入相关的函数
; 输入标点符号
; 输入字符
; 输入音调
ImeInputChar(input_char, pos := -1, try_puts := 0)
{
    global ime_input_caret_pos
    global ime_input_string
    global ime_auxiliary_code
    global ime_input_candidate
    global tooltip_debug

    update_coord := false
    tooltip_debug := []
    if (!ime_input_string ) {
        update_coord := true
    }
    if( InStr("QWERTYPASDFGHJKLZXCBNM", input_char, true) ){
        ime_auxiliary_code .= input_char
    } else {
        pos := pos != -1 ? pos : ime_input_caret_pos
        ime_input_string := SubStr(ime_input_string, 1, pos) . input_char . SubStr(ime_input_string, pos+1)
        ime_input_caret_pos := pos + 1
    }
    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(input_char)
        ImeClearInputString()
    } else {
        ime_input_candidate.Initialize(ime_input_string, ime_auxiliary_code)
    }
    ImeTooltipUpdate(ime_input_string, ime_auxiliary_code, ime_input_caret_pos, ime_input_candidate, update_coord)
}

ImeInputNumber(key)
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate
    global ime_auxiliary_code

    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        start_index := Floor((ime_input_candidate.GetSelectIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
        ime_input_candidate.SetSelectIndex(start_index + (key == 0 ? 10 : key))
        PutCandidateCharacter(ime_input_candidate)
        ImeTooltipUpdate(ime_input_string, ime_auxiliary_code, ime_input_caret_pos, ime_input_candidate)
    }
    else {
        ImeInputChar(key)
    }
}
