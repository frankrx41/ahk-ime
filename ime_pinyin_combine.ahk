;*******************************************************************************
; 组词
;
PinyinResultInsertCombine(ByRef DB, ByRef save_field_array, ByRef search_result, assistant_input)
{
    local
    ; 不存在组词时自动组词
    if( save_field_array.Length() != 1 )
    {
        if( save_field_array[2,1,1]!=Chr(2) )
        {
            word := save_field_array[1,1,-1] . save_field_array[2,1,-1]
            While( InStr(word,"'") && !PinyinHasResult(word) ) {
                word := RegExReplace(word, "i)'([^']+)?$")
            }
            ; if( word ~= "^" . save_field_array[1, 0] . "'[a-z;]+" ){
            ;     PinyinUpdateKey(DB, word)
            ;     search_result := PinyinKeyGetWords(word)
            ; }
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
    rarr := ["", "", "auto"]
    loop % arr.Length()
    {
        if( arr[A_Index, 0]!=Chr(2) ){
            rarr[1] .= arr[A_Index, 1, 1]
            rarr[2] .= arr[A_Index, 1, 2]
        }
    }
    return rarr
}
