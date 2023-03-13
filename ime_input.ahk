;*******************************************************************************
; 清除输入字符
ImeClearInputString()
{
    global ime_input_string
    global ime_input_caret_pos
    global tooltip_debug

    ime_input_string := ""
    ime_input_caret_pos := 0
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
    
    string := ImeGetCandidateWord(select_index)
    occupied_characters := ImeGetCandidatePinyin(select_index)
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
    string := ImeGetCandidateWord(select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeClearInputString()
}
