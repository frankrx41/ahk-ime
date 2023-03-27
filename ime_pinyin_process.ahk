; index == 1, return itself "a" -> "a" "a1" -> "a1"
; index == 2, "a1b1c1" -> "a1b1", "a1" -> ""
GetLeftString(input_str, index, max_length:=8)
{
    ; pos := InStr(input_str, "|")
    is_last_char := false
    test_string := RegExReplace(input_str, "(\d)", "'")
    if( SubStr(test_string, 0, 1) != "'" ){
        test_string .= "'"
        is_last_char := true
    }
    max_pos := InStr(test_string, "'",, 1, max_length)
    max_pos := max_pos ? max_pos - StrLen(test_string) : 0
    cut_pos := InStr(test_string, "'",, max_pos, index) ; negative
    left_string := SubStr(input_str, 1, cut_pos)
    return left_string
}

PinyinProcess(ByRef DB, ByRef save_field_array, input_spilt_string)
{
    local
    global history_field_array  ; TODO: remove this, and remove `save_field_array`
    input_string := input_spilt_string
    begin := A_TickCount

    loop
    {
        if( !input_string ){
            break
        }
        if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
            Assert(0, "Forward timeout")
            break
        }
        
        loop
        {
            ; "wo'xi'huan'ni" -> ["wo'xi'huan'ni"] -> ["wo'xi'huan" + "ni"] -> ["wo'xi" + "huan'ni"] -> ["wo" + "xi'huan'ni"]
            input_left := GetLeftString(input_string, A_Index)
            if( !input_left ){
                input_string := ""
                break
            }
            if( input_left ){
                PinyinHistoryUpdateKey(DB, input_left)
                if( PinyinHistoryHasKey(input_left) && PinyinHistoryHasResult(input_left) ){
                    save_field_array.Push(CopyObj(history_field_array[input_left]))
                    input_string := SubStr(input_string, StrLen(input_left)+1)
                    break
                }
            }
        }
    }
}
