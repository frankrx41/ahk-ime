ImeInputterHistoryClear()
{
    global ime_input_string_history
    ime_input_string_history := []      ; ["select"] := current_index
    ime_input_string_history["select"] := 0

    ImeInputterHistoryPush("h=======================")  ; 202 ms in radical
    ImeInputterHistoryPush("woconglaibuchengren ziji hui shu")
    ImeInputterHistoryPush("haomiao yinei")
    ImeInputterHistoryPush("zaichanganaotuolijinxingtudigaige")
    ; ImeInputterHistoryPush("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    ; ImeInputterHistoryPush("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww")
    ImeInputterHistoryPush("wohenaini")
}

;*******************************************************************************
;
ImeInputterHistorySummon(offset)
{
    global ime_input_string_history
    ; ime_input_string_history.Push(ime_input_string)
    ime_input_string_history["select"] += offset
    if( ime_input_string_history["select"] <= 0 ){
        ime_input_string_history["select"] := ime_input_string_history.Length()
    }
    if( ime_input_string_history["select"] > ime_input_string_history.Length() ){
        ime_input_string_history["select"] := 1
    }
    select_index := ime_input_string_history["select"]
    return ime_input_string_history[select_index]
}

ImeInputterHistoryPush(input_string)
{
    global ime_input_string_history
    ime_input_string_history.Push(input_string)
}
