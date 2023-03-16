;*******************************************************************************
; 词组联想
;
PinyinResultInsertAssociate(ByRef DB, ByRef search_result, srf_all_Input_tip, tfzm)
{
    local
    global history_field_array

    if( !tfzm && InStr(srf_all_Input_tip, "'", , 1, 3) )
    {
        if( history_field_array[srf_all_Input_tip, -1]==="" ){
            history_field_array[srf_all_Input_tip, -1] := PinyinSqlGetResult(DB, srf_all_Input_tip)
        }
        loop % tt:=history_field_array[srf_all_Input_tip, -1].Length() {
            search_result.InsertAt(2, CopyObj(history_field_array[srf_all_Input_tip, -1, tt+1-A_Index]))
        }
    }
    return
}
