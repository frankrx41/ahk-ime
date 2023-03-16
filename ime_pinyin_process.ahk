; HistoryCheckPosUpdateSaved
PinyinProcess1(ByRef save_field_array, ByRef history_cutpos, srf_all_Input_for_trim)
{
    local
    check_str := ""
    index     := 0
    loop % save_field_array.Length() ; "wxhns", then "wxhnsa"
    {
        if( save_field_array[A_Index,0] == Chr(1) || save_field_array[A_Index,0] == "" ){
            Assert(0, "Unknow error with: " . srf_all_Input_for_trim)
            index := A_Index
            break
        }
        
        check_str .= save_field_array[A_Index,0] "'"
        if( InStr("^" . srf_all_Input_for_trim "'", "^" . check_str) ){
            ; 已经被记录过，标记可以跳过
            history_cutpos.Push(StrLen(check_str))
        } else {
            ; 没有被记录，标记删除数据
            index := A_Index
            break
        }
    }
    if( index ) {
        save_field_array.RemoveAt(index, save_field_array.Length()-index+1)
    }
}

PinyinProcess2(ByRef DB, ByRef save_field_array, ByRef history_cutpos, srf_all_Input_for_trim, zisu)
{
    local
    global history_field_array
    if( save_field_array.Length()>0 )
    {
        if( history_cutpos.Length()>1 )
        {
            word := SubStr(srf_all_Input_for_trim, history_cutpos[history_cutpos.Length()], 1)
            if( word != "'" ) {
                history_cutpos.Pop()
                save_field_array.Pop()
            }
        }

        begin := A_TickCount
        loop % history_cutpos.Length()
        {
            if( A_TickCount - begin > 50 && !Mod(A_Index, 20) ){
                Msgbox, % "Backtrack timeout"
                break
            }

            srf_all_Input_trim_off := SubStr(srf_all_Input_for_trim, history_cutpos[A_Index]+1)
            if( srf_all_Input_trim_off == "" ){
                break
            }
            if( InStr(srf_all_Input_trim_off, "'", , 1, zisu) ){
                continue
            }
            if( !PinyinHasKey(srf_all_Input_trim_off) )
            {
                PinyinUpdateKey(DB, srf_all_Input_trim_off)
                if( !PinyinHasResult(srf_all_Input_trim_off) )
                {
                    if( !InStr(srf_all_Input_trim_off, "'") ){
                        history_field_array[srf_all_Input_trim_off] := {0:srf_all_Input_trim_off, 1:[srf_all_Input_trim_off,srf_all_Input_trim_off=Chr(2)?"":srf_all_Input_trim_off]}
                    }
                    continue
                }
                else if( A_Index > 1 )
                {
                    history_field_array[srf_all_Input_trim_off].Push("")
                }
            }
            ; Save into history_cutpos
            if( PinyinHasResult(srf_all_Input_trim_off) )
            {
                temp_result := {}
                loop_cnt := A_Index-1
                loop % loop_cnt
                {
                    if( save_field_array[A_Index, 0] ){
                        temp_result.Push(save_field_array[A_Index])
                    }
                }
                temp_result.Push(CopyObj(history_field_array[srf_all_Input_trim_off]))
                save_field_array := temp_result

                history_cutpos := [0]
                loop % save_field_array.Length()
                {
                    history_cutpos[A_Index+1] := history_cutpos[A_Index] + StrLen(save_field_array[A_Index,0]) + 1
                }
            }
        }
    }
}

; index == 1, return itself
; index == 2, "a1b1c1" -> "a1b1", "a1" -> ""
GetLeftString(input_str, index, max_length:=8)
{
    ; pos := InStr(input_str, "|")
    test_string := RegExReplace(input_str, "(\d)", "'")
    max_pos := InStr(test_string, "'",, 1, max_length)
    max_pos := max_pos ? max_pos - StrLen(test_string) : 0
    cut_pos := InStr(test_string, "'",, max_pos, index) ; negative
    left_string := SubStr(input_str, 1, cut_pos)
    return left_string
}

PinyinProcess3(ByRef DB, ByRef save_field_array, origin_input_string)
{
    local
    global history_field_array
    input_string := origin_input_string
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
                break
            }
            if( input_left ){
                PinyinUpdateKey(DB, input_left)
                if( PinyinHasKey(input_left) && PinyinHasResult(input_left) ){
                    save_field_array.Push(CopyObj(history_field_array[input_left]))
                    input_string := SubStr(input_string, StrLen(input_left)+1)
                    break
                }
            }
        }
    }
}

PinyinProcess(ByRef DB, ByRef save_field_array, srf_all_Input_for_trim)
{
    local
    history_cutpos  :=[0]

    ; 正向最大划分
    ; Clear saved history
    ; PinyinProcess1(save_field_array, history_cutpos, srf_alwl_Input_for_trim)
    ; 
    ; PinyinProcess2(DB, save_field_array, history_cutpos, srf_all_Input_for_trim, zisu)
    ; 
    PinyinProcess3(DB, save_field_array, srf_all_Input_for_trim)
}
