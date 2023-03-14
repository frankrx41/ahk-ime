PinyinHasResult(pinyin)
{
    global history_field_array
    return history_field_array[pinyin, 1, 2] != ""
}

PinyinHasKey(pinyin)
{
    global history_field_array
    global tooltip_debug
    tooltip_debug[3] .= "`n[" pinyin ": " history_field_array.HasKey(pinyin) "]"
    return history_field_array.HasKey(pinyin)
}

PinyinAddWords(ByRef DB, ByRef save_field_array, ByRef search_result)
{
    local
    global history_field_array
    scheme := "pinyin"
    ; 插入候选词部分
    ; 比如 "kaixina" 会提取出 "kaixin" 然后判断是否有词组
    if( word := RegExReplace(save_field_array[1,1,-1], "i)'[^']+$") )
    {
        While( InStr(word,"'") && !PinyinHasResult(word) )
        {
            if( !PinyinHasKey(word) )
            {
                history_field_array[word] := Get_jianpin(DB, scheme, "'" word "'", "", 0, 0)
                if( PinyinHasResult(word) ){
                    break
                }
            }
            word := RegExReplace(word, "i)'([^']+)?$")
        }
        if( InStr(word,"'") )
        {
            if( history_field_array[word].Length()==2 && history_field_array[word,2,2]=="" ){
                history_field_array[word] := Get_jianpin(DB, scheme, "'" word "'", "", 0, 0)
            }
            loop % history_field_array[word].Length() {
                search_result.Push(CopyObj(history_field_array[word, A_Index]))
            }
            ; 存在两个 ' 在词组中，比如 "wxhn" -> "wx"
            if( t:= InStr(word, "'", , , 2) )
            {
                ; Assert(0, "二字词: " . save_field_array[1, 0])
                word := SubStr(word,1,t-1)
                if( !PinyinHasKey(word) || history_field_array[word].Length()==2 && history_field_array[word,2,2]=="" ){
                    history_field_array[word]:= Get_jianpin(DB, scheme, "'" word "'", "", 0, 0)
                }
                if( PinyinHasResult(word) ){
                    loop % history_field_array[word].Length(){
                        search_result.Push(CopyObj(history_field_array[word, A_Index]))
                    }
                }
            }
        }
    }
    return
}

PinyinProcess5(ByRef DB, ByRef search_result, srf_all_Input_tip)
{
    local
    global history_field_array
    scheme := "pinyin"
    first_word := SubStr(srf_all_Input_tip, 1, InStr(srf_all_Input_tip "'", "'")-1)
    if( first_word != srf_all_Input_tip )
    {
        if( !PinyinHasKey(first_word) || (history_field_array[first_word].Length()==2 && history_field_array[first_word,2,2]=="") )
        {
            history_field_array[first_word] := Get_jianpin(DB, scheme, "'" first_word "'", "", 0, 0)
        }
        loop % history_field_array[first_word].Length()
        {
            search_result.Push(CopyObj(history_field_array[first_word, A_Index]))
        }
    }
    return
}

PinyinHideZeroWeight(ByRef search_result, hide_zero_weight)
{
    local
    if( hide_zero_weight && search_result[1, 3]>0 )
    {
        loop % len := search_result.Length()
        {
            weight := search_result[len+1-A_Index, 3]
            if( weight<=0 ) {
                search_result.RemoveAt(len+1-A_Index)
            }
        }
    }
    return
}

PinyinRemoveZeroIndex(ByRef search_result)
{
    ; [0] is store "pinyin"
    if( search_result.HasKey(0) ){
        search_result.Delete(0)
    }
    return
}

; 拼音取词
PinyinGetSentences(ime_orgin_input)
{
    local
    global DB
    static save_field_array := []

    srf_all_Input_for_trim  := Trim(PinyinSplit(ime_orgin_input, "pinyin", 0, DB), "'")
    ime_auxiliary_input     := ""
    search_result           := []

    ; ?
    PinyinProcess1(DB, save_field_array, srf_all_Input_for_trim, ime_orgin_input, 10)

    ; 组词
    PinyinCombine(DB, save_field_array, search_result, ime_auxiliary_input)
    ; 插入前面个拼音所能组成的候选词
    PinyinAddWords(DB, save_field_array, search_result)

    ; 逐码提示 联想
    if( false ) {
        PinyinAssociate(DB, search_result, srf_all_Input_for_trim, ime_auxiliary_input)
    }
    ; 插入字部分
    PinyinProcess5(DB, search_result, srf_all_Input_for_trim)


    ; 显示辅助码
    PinyinShowAuxiliary(search_result, 0)

    ; 辅助码或超级简拼
    if( false ) {
        ; 使用任意一或二位辅助码协助筛选候选项去除重码
        PinyinAuxiliaryCheck(search_result, ime_auxiliary_input)
    } else {
        ; 超级简拼 显示 4~8 字简拼候选
        if( false ) {
            PinyinSimpleSpell(DB, search_result, ime_orgin_input, 0)
        }
    }

    ; 隐藏词频低于 0 的词条，仅在无其他候选项的时候出现
    PinyinHideZeroWeight(search_result, 1)


    PinyinRemoveZeroIndex(search_result)
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    return search_result
}
