DisplaySelectItems()
{
    local
    column          := ImeSelectorGetColumn()
    select_index    := ImeTranslatorGetSelectIndex()
    ime_select_str  := "----------------"
    start_index     := ImeSelectorShowMultiple() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeSelectorShowMultiple() ? Floor(ImeTranslatorGetListLength() / column) +1 : 1
    max_item_len    := []
    max_column_loop := 6

    if( column_loop > max_column_loop ) {
        column_loop := max_column_loop
        start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
        start_index := Min(start_index, (Floor((ImeTranslatorGetListLength()-1) / column)-max_column_loop+1)*column)
    }

    loop % Min(ImeTranslatorGetListLength(), column) {
        word_index      := start_index + A_Index
        ime_select_str  .= "`n"
        row_index       := A_Index

        loop % column_loop
        {
            item_str := ""
            ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
            in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
            if( word_index <= ImeTranslatorGetListLength() )
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
                    ; radical_code := ImeTranslatorGetIndexWordRadical(word_index)
                    ; if( radical_code ){
                    ;     radical_code := "{" radical_code "}"
                    ; }
                }

                end_str := select_index == word_index ? "]" : " "
                comment := ImeTranslatorGetCommentDisplayText(word_index)

                item_str := begin_str . ImeTranslatorGetWord(word_index) . radical_code . end_str . comment
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

    input_string := ime_input_string
    caret_pos := ime_input_caret_pos

    if( !input_string )
    {
        ToolTip(1, "")
        ime_tooltip_pos := ""
    }
    else
    {
        if( ImeSelectorIsOpen() ){
            ime_select_str := DisplaySelectItems()
        } else {
            ime_select_str := ImeTranslatorGetWord(ImeTranslatorGetSelectIndex())
        }

        ; Update pos
        if( tooltip_pos != "" ){
            ime_tooltip_pos := tooltip_pos
        }
        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        ; Debug info
        debug_tip := "`n----------------`n" "[" ImeTranslatorGetSelectIndex() "/" ImeTranslatorGetListLength() "] (" ImeTranslatorGetWeight(ImeTranslatorGetSelectIndex()) ")"
        debug_tip .= " {" WordGetRadical(ImeTranslatorGetWord(ImeTranslatorGetSelectIndex()), 10) "}"
        debug_tip .= " (" ImeTranslatorGetPinyin(ImeTranslatorGetSelectIndex()) ")"
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


        tooltip_string := SubStr(input_string, 1, caret_pos) "|" SubStr(input_string, caret_pos+1)
        tooltip_string .= "(" caret_pos ")"
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
