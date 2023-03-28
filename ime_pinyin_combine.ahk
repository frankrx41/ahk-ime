;*******************************************************************************
; 组词，字数大于1
;
PinyinResultInsertCombine(ByRef DB, ByRef save_field_array, ByRef search_result)
{
    local
    ; 存在词组时添加之 e.g. wo3ai4ni3
    if( save_field_array.Length() == 1 )
    {
        loop % save_field_array[1].Length() {
            search_result.Push(CopyObj(save_field_array[1, A_Index]))
        }
    }
    return
}
