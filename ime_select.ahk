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
