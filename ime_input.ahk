;*******************************************************************************
; 清除输入字符
ImeClearInputString()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_select_index
    global ime_open_select_menu

    ime_input_string := ""
    ime_input_caret_pos := 0
    ime_select_index := 1
    ime_open_select_menu := 0
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

