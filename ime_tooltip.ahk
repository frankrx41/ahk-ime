DisplaySelectItems(candidate)
{
    local
    column          := GetSelectMenuColumn()
    select_index    := candidate.GetSelectIndex()
    ime_select_str  := "----------------"
    start_index     := ImeIsSelectMenuMore() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeIsSelectMenuMore() ? Floor(candidate.GetListLength() / column) +1 : 1
    max_item_len    := []
    max_column_loop := 6

    if( column_loop > max_column_loop ) {
        column_loop := max_column_loop
        start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
        start_index := Min(start_index, (Floor((candidate.GetListLength()-1) / column)-max_column_loop+1)*column)
    }

    loop % Min(candidate.GetListLength(), column) {
        word_index      := start_index + A_Index
        ime_select_str  .= "`n"
        row_index       := A_Index

        loop % column_loop
        {
            item_str := ""
            ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
            in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
            if( word_index <= candidate.GetListLength() )
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
                auxiliary_code := candidate.GetAuxiliary(word_index)
                if( auxiliary_code ){
                    auxiliary_code := "{" auxiliary_code "}"
                }
                item_str := begin_str . candidate.GetWord(word_index) . auxiliary_code . end_str
                ; item_str := begin_str . ImeGetCandidateWord(word_index) . ImeGetCandidateDebugInfo(word_index) . end_str
            } else {
                item_str := ""
            }
            len := StrPut(item_str, "CP936")
            if( row_index == 1 ) {
                max_item_len[A_Index] := len + 1
            }
            loop, % Max(12, max_item_len[A_Index]) - len {
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
ImeTooltipUpdate(input_string, caret_pos:=0, candidate:=0, update_coord:=0)
{
    local
    static ime_tooltip_pos := ""
    global tooltip_debug
    global opt_show_debug_tooltip

    if( !input_string )
    {
        ToolTip(1, "")
    }
    else
    {
        if( candidate ) {
            if( ImeIsSelectMenuOpen() ){
                ime_select_str := DisplaySelectItems(candidate)
            } else {
                ime_select_str := candidate.GetWord(candidate.GetSelectIndex())
            }
        }

        if( update_coord || ime_tooltip_pos == "" ){
            ime_tooltip_pos := GetCaretPos()
        }

        debug_tip := "`n----------------`n" "[" candidate.GetSelectIndex() "/" candidate.GetListLength() "] (" candidate.GetWeight(candidate.GetSelectIndex()) ") "
        debug_tip .= "{" GetAuxiliaryTable(candidate.GetWord(candidate.GetSelectIndex()), 10) "}"
        debug_tip .= "`n" tooltip_debug[1]  ; Spilt word
        debug_tip .= "`n" tooltip_debug[6]  ; Auxiliary
        debug_tip .= "`n" tooltip_debug[7]  ; Check weight
        ; debug_tip .= "`n" tooltip_debug[3]  ; SQL
        debug_tip .= "`n" tooltip_debug[11] ; Candidate
        debug_tip .= "`n" tooltip_debug[18] ; Assert info

        tooltip_string := SubStr(input_string, 1, caret_pos) "|" SubStr(input_string, caret_pos+1)
        ToolTip(1, tooltip_string "(" caret_pos ")" "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
