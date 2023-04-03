;*******************************************************************************
;
ImeOutputterPutSelect(as_legacy)
{
    local
    input_string := ImeSelectorGetOutputString(as_legacy)
    if( input_string )
    {
        PutString(input_string, false)
    }

    ImeInputterClearString()
    ImeSelectMenuClose()
}

; 以词定字
; PutCharacterWordByWord(select_index, offset)
; {
;     local
;     split_index := ImeInputterGetCaretSplitIndex()
;     string := ImeTranslatorResultListGetWord(split_index, select_index)
;     PutCharacter( SubStr(string, offset, 1) )
;     ImeInputterClearString()
;     ImeSelectMenuClose()
;     ImeSelectorApplyCaretSelectIndex(true)
; }
