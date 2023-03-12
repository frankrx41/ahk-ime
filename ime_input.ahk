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
    ime_input_string := SubStr(ime_input_string, StrLen(occupied_characters)+1-StrLen(string)+1)
    ; MsgBox, % StrLen(occupied_characters) "`n" ime_input_string
    PutCharacter( string )
    if( !ime_input_string ) {
        ImeClearInputString()
    }
}

PutCharacterWordByWord(select_index, offset)
{
    global ime_candidate_sentences
    global ime_input_string

    string := ime_candidate_sentences[select_index,2]
    PutCharacter( SubStr(string, offset, 1) )
    ImeClearInputString()
}
