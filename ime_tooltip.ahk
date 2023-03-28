DisplaySelectItems()
{
    local
    global ime_input_caret_pos
    column          := ImeSelectorGetColumn()
    ime_select_str  := "----------------"
    max_column_loop := 6

    loop % ImeTranslatorGetWordCount()
    {
        split_index     := A_Index
        select_index    := ImeTranslatorResultGetSelectIndex(split_index)
        if( select_index == 0 ){
            continue
        }
        if( split_index != ImeTranslatorGetPosSplitIndex(ime_input_caret_pos) )
        {
            continue
        }
        start_index     := ImeSelectorShowMultiple() ? 0 : Floor((select_index-1) / column) * column
        column_loop     := ImeSelectorShowMultiple() ? Floor(ImeTranslatorResultGetListLength(split_index) / column) +1 : 1

        max_item_len    := []

        if( column_loop > max_column_loop ) {
            column_loop := max_column_loop
            start_index := Max(0, (Floor((select_index-1) / column)-max_column_loop+2)*column)
            start_index := Min(start_index, (Floor((ImeTranslatorResultGetListLength(split_index)-1) / column)-max_column_loop+1)*column)
        }

        loop % Min(ImeTranslatorResultGetListLength(split_index), column) {
            word_index      := start_index + A_Index
            ime_select_str  .= "`n"
            row_index       := A_Index

            loop % column_loop
            {
                item_str := ""
                ; in_column := word_index / column >= start_index && word_index / column <= start_index + column
                in_column := (Floor((word_index-1) / column) == Floor((select_index-1) / column))
                if( word_index <= ImeTranslatorResultGetListLength(split_index) )
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

                    end_str := select_index == word_index ? "]" : " "
                    comment := ImeTranslatorResultGetFormattedComment(split_index, word_index)

                    item_str := begin_str . ImeTranslatorResultGetWord(split_index, word_index) . radical_code . end_str . comment
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
    return ime_select_str
}

ImeTooltipUpdatePos()
{
    ImeTooltipUpdate(GetCaretPos())
}

ImeTooltipDebugTipAdd(ByRef debug_tip, index, max_length := 50)
{
    if( ImeProfilerGetCount(index) >= 1 ){
        debug_tip .= "`n" . index . "*" ImeProfilerGetCount(index) ":"
        debug_tip .= "(" ImeProfilerGetTotalTick(index) ") "
        debug_tip .= SubStr(ImeProfilerGetDebugInfo(index), 1, max_length)
    }
}

ImeTooltipUpdate(tooltip_pos := "")
{
    local
    static ime_tooltip_pos := ""

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
            ime_select_index := ""
            ime_select_str := ""
            loop % ImeTranslatorGetWordCount()
            {
                split_index     := A_Index
                select_index    := ImeTranslatorResultGetSelectIndex(split_index)
                select_lock     := ImeTranslatorResultIsLock(split_index)
                selected_word   := ImeTranslatorResultGetWord(split_index, select_index)
                if( select_index != 0 )
                {
                    if( SubStr(ime_select_str, 0, 1) != "/" ){
                        ime_select_str .= "/"
                        ime_select_index .= "/"
                    }
                    ime_select_str .= selected_word
                }
                select_index_char := (select_index == 0) ? "-" : Mod(select_index,10)
                if( select_index != 0 && selected_word == ImeTranslatorResultGetPinyin(split_index, select_index) ) {
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
        }

        ; Update pos
        if( tooltip_pos != "" ){
            ime_tooltip_pos := tooltip_pos
        }
        if( !ime_tooltip_pos ){
            ime_tooltip_pos := GetCaretPos()
        }

        split_index := ImeTranslatorGetPosSplitIndex(ime_input_caret_pos)
        ; Debug info
        debug_tip := "`n----------------`n"
        debug_tip .= "[" ImeTranslatorResultGetSelectIndex(split_index) "/" ImeTranslatorResultGetListLength(split_index) "] (" ImeTranslatorResultGetWeight(split_index, ImeTranslatorResultGetSelectIndex(split_index)) ")"
        debug_tip .= " {" WordGetRadical(ImeTranslatorResultGetWord(split_index, ImeTranslatorResultGetSelectIndex(split_index)), 10) "}"
        debug_tip .= " (" ImeTranslatorResultGetPinyin(split_index, ImeTranslatorResultGetSelectIndex(split_index)) ")"
        ImeTooltipDebugTipAdd(debug_tip, 11)    ; PinyinSplit
        ImeTooltipDebugTipAdd(debug_tip, 14, 0) ; PinyinHistoryHasKey
        ImeTooltipDebugTipAdd(debug_tip, 15)    ; PinyinSqlGetResult
        ImeTooltipDebugTipAdd(debug_tip, 16, 2000)    ; PinyinSqlGetResult
        ImeTooltipDebugTipAdd(debug_tip, 20)    ; PinyinGetTranslateResult
        ImeTooltipDebugTipAdd(debug_tip, 22)    ; PinyinResultInsertSimpleSpell
        ImeTooltipDebugTipAdd(debug_tip, 26)    ; PinyinResultFilterByRadical
        ImeTooltipDebugTipAdd(debug_tip, 27)    ; PinyinResultFilterSingleWord
        ImeTooltipDebugTipAdd(debug_tip, 28)    ; PinyinResultUniquify
        ImeTooltipDebugTipAdd(debug_tip, 1)     ; temp
        ImeTooltipDebugTipAdd(debug_tip, 2)     ; tick
        ImeTooltipDebugTipAdd(debug_tip, 4)     ; assert info


        tooltip_string := SubStr(input_string, 1, caret_pos) "|" SubStr(input_string, caret_pos+1)
        tooltip_string := StrReplace(tooltip_string, " ", "_")
        tooltip_string .= "(" caret_pos ")"
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
