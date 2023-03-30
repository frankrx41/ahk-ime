; 字符上屏
PutCharacter(str, mode:=""){
    Critical
    SendInput, % "{Text}" str
}

PutCandidateCharacter()
{
    local
    PutCharacter( ImeTranslatorGetOutputString() )
    ImeInputterClearString()
}

; 以词定字
PutCharacterWordByWord(select_index, offset)
{
    local
    split_index := ImeInputterGetCaretSplitIndex()
    string := ImeTranslatorResultGetWord(split_index, select_index)
    PutCharacter( SubStr(string, offset, 1) )
    ImeInputterClearString()
    ImeSelectorOpen(false)
}
