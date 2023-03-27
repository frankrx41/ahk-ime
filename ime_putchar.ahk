; 字符上屏
PutCharacter(str, mode:=""){
    Critical
    SendInput, % "{Text}" str
}

PutCandidateCharacter()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global DB

    send_word := TranslatorSendWordThenUpdate()
    PutCharacter( send_word )

    before_input_string := ime_input_string
    ime_input_string := TranslatorGetRemainString()
    ime_input_caret_pos -= StrLen(before_input_string) - StrLen(ime_input_string)

    if( !ime_input_string )
    {
        ImeInputterClearString()
        ImeSelectorOpen(false)
    }
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    local
    string := TranslatorGetWord(select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeInputterClearString()
    ImeSelectorOpen(false)
}
