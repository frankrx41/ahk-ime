; 字符上屏
PutCharacter(str, mode:=""){
    Critical
    SendInput, % "{Text}" str
}

PutCandidateCharacter()
{
    local
    global ime_input_caret_pos
    global DB

    PutCharacter( ImeTranslatorGetResultString() )
    ImeInputterClearString()
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    local
    global ime_input_caret_pos
    split_index := ImeTranslatorGetPosSplitIndex(ime_input_caret_pos)
    string := ImeTranslatorGetWord(split_index, select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeInputterClearString()
    ImeSelectorOpen(false)
}
