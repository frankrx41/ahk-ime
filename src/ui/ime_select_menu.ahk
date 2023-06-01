ImeSelectMenuInitialize()
{
    global ime_selector_column              := 10       ; 最大候选词个数
    global ime_selector_is_open             := 0        ; 是否打开选字窗口
    global ime_selector_is_show_multiple    := 0        ; Show more column
}

;*******************************************************************************
;
ImeSelectMenuOpen(multiple:=false)
{
    local
    global ime_selector_is_open
    global ime_selector_is_show_multiple

    ime_selector_is_open := true
    if( ImeInputterIsInputDirty() )
    {
        ImeInputterUpdateString("")
    }

    if( multiple ){
        multiple := ImeSelectMenuCanShowMultiple()
    }
    ime_selector_is_show_multiple := multiple
}

ImeSelectMenuClose()
{
    global ime_selector_is_open
    ime_selector_is_open := false
}

ImeSelectMenuIsOpen()
{
    global ime_selector_is_open
    return ime_selector_is_open
}

ImeSelectMenuIsMultiple()
{
    global ime_selector_is_show_multiple
    return ime_selector_is_show_multiple
}

ImeSelectMenuCanShowMultiple()
{
    split_index := ImeInputterGetCaretSplitIndex()
    return ImeCandidateGetTranslatorListLength(split_index) > ImeSelectMenuGetColumn()
}

ImeSelectMenuGetColumn()
{
    global ime_selector_column
    return ime_selector_column
}
