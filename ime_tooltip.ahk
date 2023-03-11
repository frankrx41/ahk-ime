
; 更新提示
ImeUpdateTooltip:
if(ime_input_string){
    if (!ime_screeen_caret) {
        ime_screeen_caret := GetCaretPos()
    }
    tooltip_string := SubStr(ime_input_string, 1, ime_caret_pos) "|" SubStr(ime_input_string, ime_caret_pos+1)
    ; ToolTip, % ime_input_string "`n" tooltip_string "`n" ime_caret_pos

    if (last_ime_input != ime_input_string) {
        last_ime_input := ime_input_string
        ime_candidate_sentences := PinyinGetSentences(ime_input_string)
    }

    ime_select_tip := ""
    if( ime_open_select_menu ) {
        Loop % Min(ime_candidate_sentences.Length(), ime_max_select_cnt) {
            tvar := A_Index

            Index := ime_for_select_obj.Push(str)
            ime_select_tip .= "`n"
            if ( ime_select_index == A_Index ) {
                ime_select_tip .= "> "
            } else {
                ime_select_tip .= A_Index "."
            }
            ime_select_tip .= ime_candidate_sentences[A_Index, 2] . " " . ime_candidate_sentences[A_Index, 1] 
        }
    } else {
        ime_select_tip .= ime_candidate_sentences[ime_select_index, 2]
    }
    debug_tip := "`n----------------`n" ime_candidate_sentences.Length() "`n" ime_select_index
    ; ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_caret_pos "`n" ime_candidate_sentences.Length(), "x" ime_screeen_caret.x " y" ime_screeen_caret.Y+ime_screeen_caret.H)
    ToolTip(1, ime_input_string "`n" tooltip_string "`n" ime_select_tip debug_tip, "x" ime_screeen_caret.x " y" ime_screeen_caret.Y+ime_screeen_caret.H)
}else{
    ToolTip(1, "")
}
return