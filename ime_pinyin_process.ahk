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

PinyinProcess3(ByRef DB, ByRef save_field_array, ByRef history_cutpos, srf_all_Input_for_trim, zisu)
{
    local
    global history_field_array
    srf_all_Input_for_trim_len := StrLen(srf_all_Input_for_trim)
    test_pos := history_cutpos[history_cutpos.Length()]
    if( test_pos<srf_all_Input_for_trim_len )
    {
        loop_num := 0
        begin := A_TickCount
        loop
        {
            loop_num += 1
            if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
                Assert(0, "Forward timeout")
                break
            }

            cut_pos := InStr(srf_all_Input_for_trim "'", "'", 0, 0, loop_num)
            srf_input_spilt_trim_left  := SubStr(srf_all_Input_for_trim, test_pos+1, cut_pos-1-test_pos)
            srf_input_spilt_trim_right := SubStr(srf_all_Input_for_trim, cut_pos+1)

            if( cut_pos<test_pos+1 || srf_input_spilt_trim_left == "") {
                break
            }
            if( InStr(srf_input_spilt_trim_left, "|") )
            {
                if( srf_input_spilt_trim_left == "|" ){
                    loop_num := 0
                    history_cutpos[history_cutpos.Length()+1] := history_cutpos[history_cutpos.Length()]+1+StrLen(srf_input_spilt_trim_left)
                    test_pos := history_cutpos[history_cutpos.Length()]
                }
                continue
            }
            if( InStr(srf_input_spilt_trim_left, "'", , 1, zisu) ){
                continue
            }

            ; Get result
            if( srf_input_spilt_trim_left && !PinyinHasKey(srf_input_spilt_trim_left) )
            {
                limit_num := !!test_pos
                ; simple_spell    := !InStr(srf_all_Input, srf_input_spilt_trim_left)
                PinyinUpdateKey(DB, srf_input_spilt_trim_left, limit_num)

                if( !PinyinHasResult(srf_input_spilt_trim_left) )
                {
                    if( InStr(srf_input_spilt_trim_left,"'") ){
                        history_field_array[srf_input_spilt_trim_left] := {0:srf_input_spilt_trim_left}
                    } else {
                        ; e.g. "io"
                        history_field_array[srf_input_spilt_trim_left] := {0:srf_input_spilt_trim_left,1:[srf_input_spilt_trim_left, srf_input_spilt_trim_left=Chr(2)?"":srf_input_spilt_trim_left]}
                    }
                } else if (test_pos) {
                    history_field_array[srf_input_spilt_trim_left].Push([])
                }
            }

            if( !PinyinHasResult(srf_input_spilt_trim_left) && InStr(srf_input_spilt_trim_left,"'") )
            {
                continue
            }
            else
            {
                loop_num := 0
                if( srf_input_spilt_trim_left != "" ) {
                    save_field_array.Push(CopyObj(history_field_array[srf_input_spilt_trim_left]))
                    Assert(cut_pos == history_cutpos[history_cutpos.Length()]+1+StrLen(srf_input_spilt_trim_left))
                    history_cutpos[history_cutpos.Length()+1] := history_cutpos[history_cutpos.Length()]+1+StrLen(srf_input_spilt_trim_left)
                }
                test_pos := history_cutpos[history_cutpos.Length()]
            }
        }
    }
}

PinyinProcess(ByRef DB, ByRef save_field_array, srf_all_Input_for_trim, zisu)
{
    local
    history_cutpos  :=[0]

    ; 正向最大划分
    ; Clear saved history
    ; PinyinProcess1(save_field_array, history_cutpos, srf_alwl_Input_for_trim)
    ; 
    ; PinyinProcess2(DB, save_field_array, history_cutpos, srf_all_Input_for_trim, zisu)
    ; 
    PinyinProcess3(DB, save_field_array, history_cutpos, srf_all_Input_for_trim, zisu)
}
