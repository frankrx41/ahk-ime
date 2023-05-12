ImeTooltipInitialize()
{
    local
    font_size           := 13
    font_family         := "Microsoft YaHei Mono" ;"Ubuntu Mono derivative Powerline"
    font_bold           := false
    background_color    := "373832"
    text_color          := "d4d4d4"
    ToolTip(1, "", "", "Q0 B" background_color " T"  text_color " S" font_size, font_family, font_bold)
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

    loop % ImeCandidateGetLength()
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
        column_loop     := ImeSelectMenuIsMultiple() ? Floor(ImeCandidateGetListLength(split_index) / column) +1 : 1

        max_item_len    := []

        if( column_loop > max_column_loop ) {
            column_loop := max_column_loop
            start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
            start_index := Min(start_index, (Floor((ImeCandidateGetListLength(split_index)-1) / column)-max_column_loop+1)*column)
        }

        loop % Min(ImeCandidateGetListLength(split_index)+1, column) {
            word_index      := start_index + A_Index
            ime_select_str  .= "`n"
            row_index       := A_Index

            loop % column_loop
            {
                item_str := ""
                ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
                in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
                if( word_index <= ImeCandidateGetListLength(split_index) )
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
                    comment := ImeCandidateGetFormattedComment(split_index, word_index)
                    if( IsTraditionalComment(comment) )
                    {
                        end_str_mark := SubStr(comment, 1, 1)
                        comment := SubStr(comment, 2)
                    }
                    end_str := select_index == word_index ? "]" : end_str_mark
                    item_str := begin_str . ImeCandidateGetWord(split_index, word_index) . radical_code . end_str . comment
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
    loop % ImeCandidateGetLength()
    {
        split_index     := A_Index
        select_index    := ImeSelectorGetSelectIndex(split_index)
        select_lock     := ImeSelectorIsSelectLock(split_index)
        selected_word   := ImeCandidateGetWord(split_index, select_index)
        if( select_index != 0 )
        {
            if( SubStr(ime_select_str, 0, 1) != "/" ){
                ime_select_str .= "/"
                ime_select_index .= "/"
            }
            ime_select_str .= selected_word
        }
        select_index_char := (select_index == 0) ? "-" : Mod(select_index,10)
        if( select_index != 0 && selected_word == ImeCandidateGetPinyin(split_index, select_index) ) {
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
        word_index := 1
        loop
        {
            select_index := ImeSelectorGetSelectIndex(split_index)
            if( select_index != 0 || split_index == 0){
                break
            }
            word_index += 1
            split_index -= 1
        }
        extern_info := ""
        extern_info .= "[" ImeSelectorGetSelectIndex(split_index) "/" ImeCandidateGetListLength(split_index) "] (" ImeCandidateGetWeight(split_index, ImeSelectorGetSelectIndex(split_index)) ")"
        current_word := ImeCandidateGetWord(split_index, select_index)
        current_word := SubStr(current_word, word_index, 1)
        radical_list := RadicalWordSplit(current_word)
        radical_words := ""
        loop, % radical_list.Length()
        {
            if( radical_words ){
                radical_words .= ", "
            }
            for index, element in radical_list[A_Index]
            {
                radical_word := element
                radical_words .= radical_word ;. RadicalGetPinyin(radical_word)
            }
        }
        extern_info .= " {" radical_words "}"
        extern_info .= " (" ImeCandidateGetPinyin(split_index, ImeSelectorGetSelectIndex(split_index)) ")"
        extern_info .= " (" ImeProfilerGetTotalTick(8) ")"
        extern_info .= " (" ime_tooltip_pos.x "," ime_tooltip_pos.y "," ime_tooltip_pos.t ")"

        ; Debug info
        debug_tip := ImeDebugGetDisplayText()

        inputter_string := ImeInputterGetDisplayString()
        tooltip_string := inputter_string "`n" ime_select_str "`n" extern_info debug_tip
        ; tooltip_string := inputter_string "`n" ime_select_str "`n" extern_info

        ImeTooltipShow(tooltip_string, ime_tooltip_pos.X, ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}

ImeTooltipShow(tooltip_string, x, y)
{
    local
    hwnd := ToolTip(1, tooltip_string, "", "x" x " y" y)

    new_x := x
    new_y := y
    WinGetPos, , , w, h, ahk_id %hwnd%
    if( x + w > A_ScreenWidth ){
        new_x := A_ScreenWidth - w
    }
    if( y + h > A_ScreenHeight ){
        new_y := A_ScreenHeight - h
    }
    ; tooltip, % x "," y "," w "," h "`n" A_ScreenWidth "," A_ScreenHeight "`n" new_x "," new_y
    ; tooltip, % x "," y "," w "," h "`n" A_ScreenWidth "," A_ScreenHeight

    ; Update tooltip pos
    if( x != new_x || y != new_y ) {
        ToolTip(1, tooltip_string, "", "x" new_x " y" new_y)
    }
}
