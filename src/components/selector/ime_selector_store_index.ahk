ImeSelectorStoreSelectInitialize()
{
    global ime_selector_store_select_index
}

ImeSelectorStoreSelectClear()
{
    global ime_selector_store_select_index
    ime_selector_store_select_index := 0
}

;*******************************************************************************
;
ImeSelectorStoreSelectIndexBeforeMenuOpen()
{
    global ime_selector_store_select_index
    ime_selector_store_select_index := ImeSelectorGetCaretSelectIndex()
}

ImeSelectorCancelCaretSelectIndex()
{
    global ime_selector_select_list
    global ime_selector_store_select_index
    split_index := ImeInputterGetCaretSplitIndex()
    SelectorResultSetSelectIndex(ime_selector_select_list[split_index], ime_selector_store_select_index)
}
