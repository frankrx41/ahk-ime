ImeOutputterInitialize()
{
    global ime_send_by_clipboard_process_list
    ime_send_by_clipboard_process_list := { "Tabletop Simulator.exe": 1 }
}

;*******************************************************************************
;
ImeOutputterPutSelect(as_legacy, word_by_word:=0)
{
    local
    global ime_send_by_clipboard_process_list

    input_string := ImeSelectorGetOutputString(as_legacy)
    if( word_by_word == 1 ){
        input_string := SubStr(input_string, 1, 1)
    }
    if( word_by_word == -1 ){
        input_string := SubStr(input_string, 0, 1)
    }

    if( input_string )
    {
        ImeInputterHistoryPush(ImeInputterStringGetLegacy())
        WinGet, process_name, ProcessName, A
        use_clipboard := ime_send_by_clipboard_process_list[process_name]
        PutString(input_string, use_clipboard)
    }

    ImeSchemeSimpleSet(false)

    ImeInputterClearAll()
    ImeSelectMenuClose()
}
