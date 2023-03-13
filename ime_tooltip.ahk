DisplaySelectItems()
{
    local
    global ime_candidate_sentences

    column          := GetSelectMenuColumn()
    select_index    := GetSelectWordIndex()
    ime_select_str  := "----------------"
    start_index     := ImeIsSelectMenuMore() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeIsSelectMenuMore() ? Floor(ime_candidate_sentences.Length() / column) +1 : 1
    max_item_len    := []
    max_column_loop := 6

    if( column_loop > max_column_loop ) {
        column_loop := max_column_loop
        start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
        start_index := Min(start_index, (Floor((ime_candidate_sentences.Length()-1) / column)-max_column_loop+1)*column)
    }

    loop % Min(ime_candidate_sentences.Length(), column) {
        word_index      := start_index + A_Index
        ime_select_str  .= "`n"
        row_index       := A_Index

        loop % column_loop
        {
            item_str := ""
            ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
            in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
            if( word_index <= ime_candidate_sentences.Length() )
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
                ; if( in_column ) {
                ;     end_str .= Floor(ime_candidate_sentences[word_index, 3]/100)
                ; }
                item_str := begin_str . ime_candidate_sentences[word_index, 2] . end_str
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
    global ime_candidate_sentences
    global ime_input_caret_pos
    global ime_tooltip_pos
    static last_ime_input := ""

    if( !ime_input_string )
    {
        ToolTip(1, "")
    }
    else
    {
        if (last_ime_input != ime_input_string) {
            last_ime_input := ime_input_string
            ime_candidate_sentences := PinyinGetSentences(ime_input_string)
        }

        if( ImeIsSelectMenuOpen() ){
            ime_select_str := DisplaySelectItems()
        } else {
            ime_select_str := ime_candidate_sentences[GetSelectWordIndex(), 2]
        }

        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        debug_tip := "`n----------------`n" "[" GetSelectWordIndex() "/" ime_candidate_sentences.Length() "] (" ime_candidate_sentences[GetSelectWordIndex(), 3] ")"
        tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
