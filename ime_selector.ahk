ImeSelectInitialize()
{
    global ime_selectmenu_column    := 10       ; 最大候选词个数
    global ime_selectmenu_open      := 0        ; 是否打开选字窗口
    global ime_selectmenu_more      := 0        ; Show more column
}

;*******************************************************************************
ImeOpenSelectMenu(open, more := false)
{
    global ime_selectmenu_open
    global ime_selectmenu_more

    ime_selectmenu_open := open
    ime_selectmenu_more := more
    return
}

ImeIsSelectMenuOpen()
{
    global ime_selectmenu_open
    return ime_selectmenu_open
}

ImeIsSelectMenuMore()
{
    global ime_selectmenu_more
    return ime_selectmenu_more
}

GetSelectMenuColumn()
{
    global ime_selectmenu_column
    return ime_selectmenu_column
}

