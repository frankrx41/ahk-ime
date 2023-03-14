PinyinProcess1(ByRef DB, ByRef save_field_array, srf_all_Input_for_trim, srf_all_Input, zisu)
{
    local
    global history_field_array
    history_cutpos  :=[0]
    index           := 0
    if( true )
    {
        ; 正向最大划分

        ; Clear saved history
        check_str := ""
        loop % save_field_array.Length()
        {
            if( save_field_array[A_Index,0] == Chr(1)){
                continue
            }
            if( save_field_array[A_Index,0] == "" ){
                index := A_Index
                break
            }
            
            check_str .= save_field_array[A_Index,0] "'"
            if( InStr("^" srf_all_Input_for_trim "'", "^" check_str) ){
                t := StrSplit(save_field_array[A_Index,0],"'").Length()
                history_cutpos.Push(StrLen(check_str))
            } else {
                index := A_Index
                break
            }
        }
        if( index ) {
            save_field_array.RemoveAt(index, save_field_array.Length()-index+1)
        }

        ; 
        srf_all_Input_for_trim_len := StrLen(srf_all_Input_for_trim)
        if( save_field_array.Length()>0 )
        {
            if( history_cutpos.Length()>1 && SubStr(srf_all_Input_for_trim, history_cutpos[history_cutpos.Length()], 1) != "'" )
            {
                history_cutpos.Pop()
                save_field_array.Pop()
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
                    PinyinUpdateKey(DB, srf_all_Input_trim_off, false, A_Index!=1)
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
                    tarr := {}
                    Ln  := A_Index-1
                    loop % Ln
                    {
                        if( save_field_array[A_Index, 0] ){
                            tarr.Push(save_field_array[A_Index])
                        }
                    }
                    tarr.Push(CopyObj(history_field_array[srf_all_Input_trim_off]))
                    save_field_array := tarr
                    tarr := ""
                    history_cutpos := [0]
                    loop % save_field_array.Length()
                    {
                        history_cutpos[A_Index+1] := history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
                    }
                }
            }
        }

        test_pos := history_cutpos[history_cutpos.Length()]
        if( test_pos<srf_all_Input_for_trim_len )
        {
            Loop_num := 0
            begin := A_TickCount
            loop
            {
                if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
                    Msgbox, % "Forward timeout"
                    break
                }

                cut_pos := InStr(srf_all_Input_for_trim "'", "'", 0, 0, Loop_num+=1)
                srf_Input_trim_left := SubStr(srf_all_Input_for_trim, test_pos+1, cut_pos-1-test_pos)
                if( cut_pos<test_pos+1 || srf_Input_trim_left == "") {
                    break
                }
                if( InStr(srf_Input_trim_left, "'", , 1, zisu) ){
                    continue
                }

                srf_Input_trim_right := SubStr(srf_all_Input_for_trim, cut_pos+1)
                ; Get result
                if( srf_Input_trim_left && !PinyinHasKey(srf_Input_trim_left) )
                {
                    limit_num       := !!test_pos
                    simple_spell    := !InStr(srf_all_Input, srf_Input_trim_left)
                    PinyinUpdateKey(DB, srf_Input_trim_left, false, simple_spell, limit_num)

                    if( !PinyinHasResult(srf_Input_trim_left) )
                    {
                        if( InStr(srf_Input_trim_left,"'") ){
                            history_field_array[srf_Input_trim_left] := {0:srf_Input_trim_left}
                        } else {
                            CallStack()
                            history_field_array[srf_Input_trim_left] := {0:srf_Input_trim_left,1:[srf_Input_trim_left, srf_Input_trim_left=Chr(2)?"":srf_Input_trim_left]}
                        }
                    } else if (test_pos) {
                        history_field_array[srf_Input_trim_left].Push([])
                    }
                }

                if( !PinyinHasResult(srf_Input_trim_left) && InStr(srf_Input_trim_left,"'") )
                {
                    continue
                }
                else
                {
                    t := StrSplit(srf_Input_trim_left,"'").Length()
                    Loop_num := 0
                    if( srf_Input_trim_left != "" ) {
                        save_field_array.Push(CopyObj(history_field_array[srf_Input_trim_left]))
                        Assert(cut_pos == history_cutpos[history_cutpos.Length()]+1+StrLen(srf_Input_trim_left))
                        history_cutpos[history_cutpos.Length()+1] := history_cutpos[history_cutpos.Length()]+1+StrLen(srf_Input_trim_left)
                    }
                    test_pos := history_cutpos[history_cutpos.Length()]
                }
            }
        }
    }
}
