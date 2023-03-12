; 更新提示
ImeTooltipUpdate()
{
    local
    global ime_input_string
    global ime_candidate_sentences
    global ime_input_caret_pos
    global ime_tooltip_pos
    static last_ime_input := ""

    if(ime_input_string){
        if (!ime_tooltip_pos) {
            ime_tooltip_pos := GetCaretPos()
        }
        tooltip_string := SubStr(ime_input_string, 1, ime_input_caret_pos) "|" SubStr(ime_input_string, ime_input_caret_pos+1)
        ; ToolTip, % ime_input_string "`n" tooltip_string "`n" ime_input_caret_pos

        if (last_ime_input != ime_input_string) {
            last_ime_input := ime_input_string
            ime_candidate_sentences := PinyinGetSentences(ime_input_string)
        }

        if( ImeIsSelectMenuOpen() ) {
            ime_select_tip := "----------------"
            start_index := Floor((GetSelectWordIndex()-1) / GetSelectMenuColumn()) * GetSelectMenuColumn()
            Loop % Min(ime_candidate_sentences.Length(), GetSelectMenuColumn()) {
                word_index := start_index + A_Index

                Index := ime_for_select_obj.Push(str)
                begin_str :=
                ime_select_tip .= "`n"
                if( word_index <= ime_candidate_sentences.Length() )
                {
                    if ( GetSelectWordIndex() == word_index ) {
                        begin_str .= ">["
                    } else {
                        begin_str .=  Mod(word_index, 10) "."
                        ; begin_str .=  word_index "."
                    }
                    end_str := GetSelectWordIndex() == word_index ? "]" : " "
                    ime_select_tip .= begin_str . ime_candidate_sentences[word_index, 2] . end_str . ime_candidate_sentences[word_index, 3] 
                } else {
                    ime_select_tip .= ""
                }

            }
        } else {
            ime_select_tip := ime_candidate_sentences[GetSelectWordIndex(), 2]
        }
        debug_tip := "`n----------------`n" "[" GetSelectWordIndex() "/" ime_candidate_sentences.Length() "]" "`n" ImeIsSelectMenuMore()
        ; ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_input_caret_pos "`n" ime_candidate_sentences.Length(), "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
        ; ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_select_tip debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
        ToolTip(1, tooltip_string "`n" ime_select_tip debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }else{
        ToolTip(1, "")
    }
    return
}
