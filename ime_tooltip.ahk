DisplaySelectItems(candidate)
{
    local
    column          := ImeSelectorGetColumn()
    select_index    := candidate.GetSelectIndex()
    ime_select_str  := "----------------"
    start_index     := ImeSelectorShowMultiple() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeSelectorShowMultiple() ? Floor(candidate.GetListLength() / column) +1 : 1
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
                begin_str := "  "
                radical_code := ""
                if( in_column ) {
                    if ( select_index == word_index ) {
                        begin_str := ">["
                    } else {
                        begin_str := Mod(word_index, 10) "."
                        ; begin_str :=  word_index "."
                    }
                    ; radical_code := candidate.GetIndexWordRadical(word_index)
                    ; if( radical_code ){
                    ;     radical_code := "{" radical_code "}"
                    ; }
                }

                end_str := select_index == word_index ? "]" : " "
                comment := candidate.GetCommentDisplayText(word_index)

                item_str := begin_str . candidate.GetWord(word_index) . radical_code . end_str . comment
                ; item_str := begin_str . ImeGetCandidateWord(word_index) . ImeGetCandidateDebugInfo(word_index) . end_str
            } else {
                item_str := ""
            }
            len := StrPut(item_str, "CP936")
            if( row_index == 1 ) {
                max_item_len[A_Index] := len + 1
            }
            loop, % Max(10, max_item_len[A_Index]) - len {
                item_str .= " "
            }
            ; item_str .= "(" len ")"
            ime_select_str .= item_str
            word_index += column
        }
    }
    return ime_select_str
}

ImeTooltipUpdatePos()
{
    ImeTooltipUpdate(GetCaretPos())
}

ImeTooltipUpdate(tooltip_pos := "")
{
    local
    static ime_tooltip_pos := ""
    global tooltip_debug

    global ime_input_string
    global ime_input_caret_pos
    global ime_input_candidate

    input_string := ime_input_string
    caret_pos := ime_input_caret_pos
    candidate := ime_input_candidate

    if( !input_string )
    {
        ToolTip(1, "")
        ime_tooltip_pos := ""
    }
    else
    {
        if( candidate ) {
            if( ImeSelectorIsOpen() ){
                ime_select_str := DisplaySelectItems(candidate)
            } else {
                ime_select_str := candidate.GetWord(candidate.GetSelectIndex())
            }
        }

        ; Update pos
        if( tooltip_pos != "" ){
            ime_tooltip_pos := tooltip_pos
        }
        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        ; Debug info
        debug_tip := "`n----------------`n" "[" candidate.GetSelectIndex() "/" candidate.GetListLength() "] (" candidate.GetWeight(candidate.GetSelectIndex()) ")"
        debug_tip .= " {" WordGetRadical(candidate.GetWord(candidate.GetSelectIndex()), 10) "}"
        debug_tip .= " (" candidate.GetPinyin(candidate.GetSelectIndex()) ")"
        debug_tip .= "`n" tooltip_debug[1]  ; Spilt word
        ; debug_tip .= "`n" tooltip_debug[3]  ; SQL
        ; debug_tip .= "`n" tooltip_debug[4]  ; single word
        ; debug_tip .= "`n" tooltip_debug[5]  ; PinyinHistoryHasKey
        debug_tip .= "`n" tooltip_debug[6]  ; Radical
        ; debug_tip .= "`n" tooltip_debug[7]  ; Check weight
        ; debug_tip .= "`n" tooltip_debug[8]  ; Simple spell
        debug_tip .= "`n" tooltip_debug[9]  ; temp
        ; debug_tip .= "`n" tooltip_debug[11] ; Translator
        debug_tip .= "`n" tooltip_debug[18] ; Assert info

        radical_code := candidate.GetInputRadical()
        if( radical_code ){
            tooltip_string := input_string
            tooltip_string .= " {" radical_code "|}"
        } else {
            tooltip_string := SubStr(input_string, 1, caret_pos) "|" SubStr(input_string, caret_pos+1)
            tooltip_string .= "(" caret_pos ")"
        }
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
