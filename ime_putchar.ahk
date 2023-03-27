; 字符上屏
PutCharacter(str, mode:=""){
    Critical
    SendInput, % "{Text}" str
}

PutCandidateCharacter(candidate)
{
    global ime_input_string
    global ime_input_caret_pos
    global DB

    send_word := candidate.SendWordThenUpdate(DB)
    PutCharacter( send_word )

    before_input_string := ime_input_string
    ime_input_string := candidate.GetRemainString()
    ime_input_caret_pos -= StrLen(before_input_string) - StrLen(ime_input_string)

    if( !ime_input_string )
    {
        ImeInputClearString()
        ImeOpenSelectMenu(false)
    }
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    global ime_input_candidate
    string := ime_input_candidate.GetWord(select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeInputClearString()
    ImeOpenSelectMenu(false)
}
