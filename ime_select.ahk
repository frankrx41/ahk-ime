ImeOpenSelectMenu(open)
{
    global ime_selectmenu_open
    global ime_select_index

    ime_selectmenu_open := open
    ime_select_index := 1
    return
}

ImeIsSelectMenuOpen()
{
    global ime_selectmenu_open
    return ime_selectmenu_open
}

UpdateSelectWordIndex(offset)
{
    global ime_select_index
    global ime_candidate_sentences
    global ime_selectmenu_column

    ime_select_index := Max(1, Min(ime_selectmenu_column, ime_candidate_sentences.Length(), ime_select_index + offset))
}

GetSelectWordIndex()
{
    global ime_select_index
    return ime_select_index
}
