ImeTooltipInitialize()
{
    local
    font_size           := 13
    font_family         := "Microsoft YaHei Mono" ;"Ubuntu Mono derivative Powerline"
    font_bold           := false
    background_color    := "373832"
    text_color          := "d4d4d4"
    ToolTip(1, "", "Q0 B" background_color " T"  text_color " S" font_size, font_family, font_bold)
}

;*******************************************************************************
;
IsTraditionalComment(comment)
{
    first_char := SubStr(comment, 1, 1)
    return InStr("*+", first_char)
}

;*******************************************************************************
;
ImeTooltipGetDisplaySelectItems()
{
    local
    column          := ImeSelectMenuGetColumn()
    ime_select_str  := "----------------"
    max_column_loop := 6

    loop % ImeTranslatorResultListGetLength()
    {
        split_index     := A_Index
        select_index    := ImeSelectorGetSelectIndex(split_index)
        if( select_index == 0 ){
            continue
        }
        if( split_index != ImeInputterGetCaretSplitIndex() )
        {
            continue
        }
        start_index     := ImeSelectMenuIsMultiple() ? 0 : Floor((select_index-1) / column) * column
        column_loop     := ImeSelectMenuIsMultiple() ? Floor(ImeTranslatorResultListGetListLength(split_index) / column) +1 : 1

        max_item_len    := []

        if( column_loop > max_column_loop ) {
            column_loop := max_column_loop
            start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
            start_index := Min(start_index, (Floor((ImeTranslatorResultListGetListLength(split_index)-1) / column)-max_column_loop+1)*column)
        }

        loop % Min(ImeTranslatorResultListGetListLength(split_index)+1, column) {
            word_index      := start_index + A_Index
            ime_select_str  .= "`n"
            row_index       := A_Index

            loop % column_loop
            {
                item_str := ""
                ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
                in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
                if( word_index <= ImeTranslatorResultListGetListLength(split_index) )
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
                        ; if( radical_code ){
                        ;     radical_code := "{" radical_code "}"
                        ; }
                    }

                    end_str_mark := " "
                    comment := ImeTranslatorResultGetFormattedComment(split_index, word_index)
                    if( IsTraditionalComment(comment) )
                    {
                        end_str_mark := SubStr(comment, 1, 1)
                        comment := SubStr(comment, 2)
                    }
                    end_str := select_index == word_index ? "]" : end_str_mark
                    item_str := begin_str . ImeTranslatorResultListGetWord(split_index, word_index) . radical_code . end_str . comment
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
    }
    ime_select_str .= "`n----------------"
    return ime_select_str
}

ImeTooltipGetDisplayInputString()
{
    ime_select_index := ""
    ime_select_str := ""
    loop % ImeTranslatorResultListGetLength()
    {
        split_index     := A_Index
        select_index    := ImeSelectorGetSelectIndex(split_index)
        select_lock     := ImeSelectorIsSelectLock(split_index)
        selected_word   := ImeTranslatorResultListGetWord(split_index, select_index)
        if( select_index != 0 )
        {
            if( SubStr(ime_select_str, 0, 1) != "/" ){
                ime_select_str .= "/"
                ime_select_index .= "/"
            }
            ime_select_str .= selected_word
        }
        select_index_char := (select_index == 0) ? "-" : Mod(select_index,10)
        if( select_index != 0 && selected_word == ImeTranslatorResultListGetPinyin(split_index, select_index) ) {
            ime_select_index .= select_index_char
            loop % StrPut(selected_word, "CP936") - 2 {
                ime_select_index .= "-"
            }
        }
        else
        if(selected_word || select_index == 0) {
            ime_select_index .= select_index_char . (select_lock ? "^" : "-")
        }
    }
    ime_select_str := SubStr(ime_select_str, 2) . "`n" . SubStr(ime_select_index, 2)
    ime_select_str .= "`n"
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

    if( !ImeInputterHasAnyInput() )
    {
        ToolTip(1, "")
        ime_tooltip_pos := ""
    }
    else
    {
        if( ImeSelectMenuIsOpen() ){
            ime_select_str := ImeTooltipGetDisplaySelectItems()
        } else {
            ime_select_str := ImeTooltipGetDisplayInputString()
        }

        ; Update pos
        if( tooltip_pos != "" ){
            ime_tooltip_pos := tooltip_pos
        }
        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        split_index := ImeInputterGetCaretSplitIndex()
        extern_info := ""
        extern_info .= "[" ImeSelectorGetSelectIndex(split_index) "/" ImeTranslatorResultListGetListLength(split_index) "] (" ImeTranslatorResultListGetWeight(split_index, ImeSelectorGetSelectIndex(split_index)) ")"
        radical_list := RadicalWordSplit(ImeTranslatorResultListGetWord(split_index, ImeSelectorGetSelectIndex(split_index)))
        radical_words := ""
        loop, % radical_list.Length()
        {
            radical_word := radical_list[A_Index]
            radical_words .= radical_word ;. RadicalGetPinyin(radical_word)
        }
        extern_info .= " {" radical_words "}"
        extern_info .= " (" ImeTranslatorResultListGetPinyin(split_index, ImeSelectorGetSelectIndex(split_index)) ")"

        ; Debug info
        debug_tip := ImeDebugGetDisplayText()

        tooltip_string := ImeInputterGetDisplayString()
        ToolTip(1, tooltip_string "`n" ime_select_str "`n" extern_info debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
        ; ToolTip(1, tooltip_string "`n" ime_select_str "`n" extern_info , "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
