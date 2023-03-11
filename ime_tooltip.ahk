
; 更新提示
ImeTooltipUpdate()
{
    local
    global ime_input_string
    global ime_candidate_sentences
    global ime_input_caret_pos
    global ime_selectmenu_open
    global ime_selectmenu_column
    global ime_select_index
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

        ime_select_tip := ""
        if( ime_selectmenu_open ) {
            Loop % Min(ime_candidate_sentences.Length(), ime_selectmenu_column) {
                tvar := A_Index

                Index := ime_for_select_obj.Push(str)
                begin_str :=
                ime_select_tip .= "`n"
                if ( ime_select_index == A_Index ) {
                    begin_str .= ">["
                } else {
                    if( A_Index == "10" ) {
                        begin_str .= "0."
                    }
                    else {
                        begin_str .=  A_Index "."
                    }
                }
                end_str := ime_select_index == A_Index ? "]" : " "

                ime_select_tip .= begin_str . ime_candidate_sentences[A_Index, 2] . end_str . ime_candidate_sentences[A_Index, 1] 
            }
        } else {
            ime_select_tip .= ime_candidate_sentences[ime_select_index, 2]
        }
        debug_tip := "`n----------------`n" ime_candidate_sentences.Length() "`n" ime_select_index
        ; ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_input_caret_pos "`n" ime_candidate_sentences.Length(), "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
        ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_select_tip debug_tip, "x" ime_tooltip_pos.x " y" ime_tooltip_pos.Y+ime_tooltip_pos.H)
    }else{
        ToolTip(1, "")
    }
    return
}
