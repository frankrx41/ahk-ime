;*******************************************************************************
; 清除输入字符
ImeClearInputString()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_string := ""
    ime_input_caret_pos := 0
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
    global ime_candidate_sentences
    global ime_input_string
    string := ime_candidate_sentences[select_index,2]
    occupied_characters := ime_candidate_sentences[select_index,1]
    ime_input_string := SubStr(ime_input_string, StrLen(occupied_characters)+1)
    ; MsgBox, % StrLen(occupied_characters) "`n" ime_input_string
    PutCharacter( string )
    if( !ime_input_string ) {
        ImeClearInputString()
    }
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
    global ime_tooltip_pos

    if (!ime_input_string ) {
        ime_tooltip_pos := 0
    }
    pos := pos != -1 ? pos : ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, pos) . key . SubStr(ime_input_string, pos+1)
    ime_input_caret_pos := pos + 1
    if( try_puts && StrLen(ime_input_string) == 1 ) {
        PutCharacter(key)
        ImeClearInputString()
    }
    ImeTooltipUpdate()
}

ImeInputNumber(key)
{
    ; 选择相应的编号并上屏
    if( ImeIsSelectMenuOpen() ) {
        PutCharacterByIndex(key == 0 ? 10 : key)
        ImeOpenSelectMenu(false)
        ImeTooltipUpdate()
    }
    else {
        ImeInputChar(key)
    }
}