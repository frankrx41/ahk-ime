PinyinProcess4(ByRef DB, ByRef search_result, srf_all_Input_tip, srf_all_Input_py, tfzm, fzm, associate)
{
    local
    global history_field_array
    if( !(tfzm||StrLen(fzm)==1) && (associate&&InStr(srf_all_Input_py, "'", , 1, 3)) )
    {
        if( history_field_array[srf_all_Input_tip, -1]==="" ){
            history_field_array[srf_all_Input_tip, -1] := Get_jianpin(DB, "", "'" srf_all_Input_py "'", "", 1, 0)
        }
        loop % tt:=history_field_array[srf_all_Input_tip, -1].Length() {
            search_result.InsertAt(2, CopyObj(history_field_array[srf_all_Input_tip, -1, tt+1-A_Index]))
        }
    }
    return
}
