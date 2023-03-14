PinyinCombine(ByRef DB, ByRef save_field_array, ByRef search_result, tfzm)
{
    local
    global history_field_array
    scheme := "pinyin"
    if( save_field_array[1].Length()==2 && save_field_array[1,2,2]=="" )
    {
        sql_result := Get_jianpin(DB, scheme, "'" save_field_array[1,0] "'", "", 0, 0)
        history_field_array[save_field_array[1,0]] := sql_result
        save_field_array[1] := CopyObj(sql_result)
    }

    ; 只有一种结果时，比如输入 "wo"
    if( (save_field_array.Length()==1) || (tfzm) )
    {
        search_result := CopyObj(save_field_array[1])
    }
    ; 处理多种结果 "woshei" -> "wo" + "shei"
    ; 但是有单独词语的不会 "woxihuan" -> "woxihuan"
    else
    {
        if( save_field_array[2,1,1]!=Chr(2) )
        {
            ci := save_field_array[1,1,-1] "'" save_field_array[2,1,-1]
            While( InStr(ci,"'") && !PinyinHasResult(ci) ) {
                ci := RegExReplace(ci, "i)'([^']+)?$")
            }
            if( ci ~= "^" . save_field_array[1, 0] . "'[a-z;]+" ){
                if( history_field_array[ci].Length()==2 && history_field_array[ci,2,2]=="" ) {
                    history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", "", 0, 0)
                }
                search_result := CopyObj(history_field_array[ci])
            }
        }

        if( InStr(save_field_array[1, 0], "'") ){
            loop % save_field_array[1].Length() {
                search_result.Push(CopyObj(save_field_array[1, A_Index]))
            }
        }
        search_result.InsertAt(1, CombineWord(save_field_array))
        search_result[1, 0] := "pinyin"
    }
    return
}

; 首选组词
CombineWord(arr)
{
    rarr := ["",""]
    loop % arr.Length()
    {
        if( arr[A_Index, 0]!=Chr(2) ){
            rarr[1] .= (rarr[1]?"'":"") . arr[A_Index, 1, 1]
            rarr[2] .= arr[A_Index, 1, 2]
        }
    }
    return rarr
}
