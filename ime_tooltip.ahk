DisplaySelectItems()
{
    local
    column          := GetSelectMenuColumn()
    select_index    := GetSelectWordIndex()
    ime_select_str  := "----------------"
    start_index     := ImeIsSelectMenuMore() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeIsSelectMenuMore() ? Floor(ImeGetCandidateListLength() / column) +1 : 1
    max_item_len    := []
    max_column_loop := 6

    if( column_loop > max_column_loop ) {
        column_loop := max_column_loop
        start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
        start_index := Min(start_index, (Floor((ImeGetCandidateListLength()-1) / column)-max_column_loop+1)*column)
    }

    loop % Min(ImeGetCandidateListLength(), column) {
        word_index      := start_index + A_Index
        ime_select_str  .= "`n"
        row_index       := A_Index

        loop % column_loop
        {
            item_str := ""
            ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
            in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
            if( word_index <= ImeGetCandidateListLength() )
            {
                if( in_column ) {
                    if ( select_index == word_index ) {
                        begin_str := ">["
                    } else {
                        begin_str := Mod(word_index, 10) "."
                        ; begin_str :=  word_index "."
                    }
                } else {
                    begin_str := "  "
                }

                end_str := select_index == word_index ? "]" : " "
                item_str := begin_str . ImeGetCandidateWord(word_index) . end_str
                ; item_str := begin_str . ImeGetCandidateWord(word_index) . ImeGetCandidateDebugInfo(word_index) . end_str
            } else {
                item_str := ""
            }
            len := StrPut(item_str, "CP936")
            if( row_index == 1 ) {
                max_item_len[A_Index] := len + 1
            }
            loop, % Max(8, max_item_len[A_Index]) - len {
                item_str .= " "
            }
            ; item_str .= "(" len ")"
            ime_select_str .= item_str
            word_index += column
        }
    }
    return ime_select_str
}

; 更新提示
ImeTooltipUpdate()
{
    local
    global ime_input_string
    global ime_input_caret_pos
    global ime_tooltip_pos
    global tooltip_debug

    if( !ime_input_string )
    {
        ToolTip(1, "")
    }
    else
    {
        if( ImeIsSelectMenuOpen() ){
            ime_select_str := DisplaySelectItems()
        } else {
            ime_select_str := ImeGetCandidateWord(GetSelectWordIndex())
        }

        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        debug_tip := "`n----------------`n" "[" GetSelectWordIndex() "/" ImeGetCandidateListLength() "] (" ImeGetCandidateWeight(GetSelectWordIndex()) ")"
        for _, value in tooltip_debug {
            debug_tip .= "`n" value
        }
        tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
