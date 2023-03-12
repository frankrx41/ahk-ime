DisplaySelectItems()
{
    local
    global ime_candidate_sentences

    column          := GetSelectMenuColumn()
    select_index    := GetSelectWordIndex()
    ime_select_str  := "----------------"
    start_index     := ImeIsSelectMenuMore() ? 0 : Floor((select_index-1) / column) * column
    column_loop     := ImeIsSelectMenuMore() ? Floor(ime_candidate_sentences.Length() / column) +1 : 1

    loop % Min(ime_candidate_sentences.Length(), column) {
        word_index := start_index + A_Index
        ime_select_str  .= "`n"

        loop % column_loop
        {
            item_str := ""
            if( word_index <= ime_candidate_sentences.Length() )
            {
                if ( select_index == word_index ) {
                    begin_str := ">["
                } else {
                    begin_str :=  Mod(word_index, 10) "."
                    ; begin_str :=  word_index "."
                }
                end_str := select_index == word_index ? "]" : " "
                item_str := begin_str . ime_candidate_sentences[word_index, 2] . end_str . SubStr(ime_candidate_sentences[word_index, 3],3)
            } else {
                item_str := ""
            }
            len := StrPut(item_str, "UTF-8")
            loop, % 12 - len {
                item_str .= " "
            }
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

        debug_tip := "`n----------------`n" "[" GetSelectWordIndex() "/" ime_candidate_sentences.Length() "]"
        tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
        ToolTip(1, tooltip_string "`n" ime_select_str debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }
    return
}
