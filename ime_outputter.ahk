;*******************************************************************************
;
ImeOutputterPutSelect(as_legacy, word_by_word:=0)
{
    local
    input_string := ImeSelectorGetOutputString(as_legacy)
    if( word_by_word == 1 ){
        input_string := SubStr(input_string, 1, 1)
    }
    if( word_by_word == -1 ){
        input_string := SubStr(input_string, 0, 1)
    }

    if( input_string )
    {
        PutString(input_string, false)
    }

    ImeInputterClearString()
    ImeSelectMenuClose()
}
