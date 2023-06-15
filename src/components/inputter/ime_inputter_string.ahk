;*******************************************************************************
ImeInputterStringSet(input_string)
{
    global ime_input_string
    ImeProfilerTickClear()
    ime_input_string := input_string
}

ImeInputterStringGetLegacy()
{
    global ime_input_string
    return ime_input_string
}

;*******************************************************************************
;
ImeInputterClearPrevSplitted()
{
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list

    if( ime_input_caret_pos != 0 )
    {
        left_pos := SplitterResultListGetLeftWordPos(ime_splitted_list, ime_input_caret_pos)
        ime_input_string := SubStr(ime_input_string, 1, left_pos) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := left_pos
    }

    ImeSelectorSetCaretSelectIndex(1)
    ImeInputterUpdateString("")
}

ImeInputterClearLastSplitted()
{
    global ime_input_string
    global ime_input_caret_pos

    ime_input_caret_pos := ImeInputterGetLastWordPos()
    if( ime_input_caret_pos == 0 )
    {
        ImeInputterClearAll()
        ImeSelectMenuClose()
    }
    else
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos)
        ImeSelectorSetCaretSelectIndex(1)
        ImeInputterUpdateString("")
    }
}

ImeInputterDeleteCharAtCaret(delet_before := true)
{
    global ime_input_string
    global ime_input_caret_pos

    if( delet_before && ime_input_caret_pos != 0 )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos-1) . SubStr(ime_input_string, ime_input_caret_pos+1)
        ime_input_caret_pos := ime_input_caret_pos-1
        ImeInputterUpdateString("")
    }
    if( !delet_before && ime_input_caret_pos != StrLen(ime_input_string) )
    {
        ime_input_string := SubStr(ime_input_string, 1, ime_input_caret_pos) . SubStr(ime_input_string, ime_input_caret_pos+2)
        ImeInputterUpdateString("")
    }
}

;*******************************************************************************
;
ImeInputterProcessChar(input_char, immediate_put:=false)
{
    global ime_input_caret_pos
    global ime_input_string

    if( ImeSelectMenuIsOpen() )
    {
        ; When select menu open, new input always take as radical
        input_char := Format("{:U}", input_char)
        ImeSelectorSetCaretSelectIndex(1)
    }
    if( IsSymbol(input_char) )
    {
        ; TODO: We should update result when symbol, like ma？ -> 吗？ de。 -> 的。
        ; Or move this feature to `SelectorFindGraceResultIndex`
    }

    caret_pos := ime_input_caret_pos
    ime_input_string := SubStr(ime_input_string, 1, caret_pos) . input_char . SubStr(ime_input_string, caret_pos+1)
    ime_input_caret_pos := caret_pos + 1

    if( immediate_put && StrLen(ime_input_string) == 1 ) {
        ImeOutputterPutSelect(true)
        ImeInputterClearAll()
    } else {
        ImeInputterUpdateString(input_char)
    }
}

;*******************************************************************************
;
ImeInputterGetDisplayDebugString(full:=false)
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list

    if( ime_input_string )
    {
        tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
    } else {
        tooltip_string := ""
    }
    tooltip_string := """" tooltip_string """"
    if( full )
    {
        list_string := SplitterResultListGetDisplayTextGrace(ime_splitted_list)
        if( list_string )
        {
            tooltip_string .= "`n" list_string
        }
    }
    return tooltip_string
}

ImeInputterGetDisplayString()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global ime_splitted_list

    tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
    tooltip_string := StrReplace(tooltip_string, " ", "_")
    tooltip_string .= " (" ime_input_caret_pos "|" ImeInputterGetCaretSplitIndex() ")"
    if( ImeInputterIsInputDirty() ){
        tooltip_string .= " {Enter}"
    }

    if( ImeSchemeIsPinyinDouble() || ImeSchemeIsPinyinBopomofo() || ImeSchemeIsPinyinSimple() )
    {
        tooltip_string .= "`n" SplitterResultListGetDisplayTextGrace(ime_splitted_list)
    }
    return tooltip_string
}
