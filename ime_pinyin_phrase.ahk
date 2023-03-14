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

PinyinUpdateKey(DB, pinyin, associate:=false, simple_spell:=false, limit_num:=100)
{
    global history_field_array
    if( !PinyinHasKey(pinyin) || history_field_array[pinyin].Length()==2 && history_field_array[pinyin,2,2]=="" )
    {
        history_field_array[pinyin] := Get_jianpin(DB, "pinyin", "'" pinyin "'", "", associate, limit_num, simple_spell)
    }
}

PinyinKeyGetWords(pinyin)
{
    global history_field_array
    return history_field_array[pinyin]
}

PinyinResultInsertWords(ByRef DB, ByRef save_field_array, ByRef search_result)
{
    local
    global history_field_array
    ; 插入候选词部分
    ; 比如 "kaixina" 会提取出 "kaixin" 然后判断是否有词组
    if( word := RegExReplace(save_field_array[1,1,-1], "i)'[^']+$") )
    {
        While( InStr(word,"'") && !PinyinHasResult(word) )
        {
            PinyinUpdateKey(DB, word)
            if( PinyinHasResult(word) ){
                break
            }
            word := RegExReplace(word, "i)'([^']+)?$")
        }
        if( InStr(word,"'") )
        {
            PinyinUpdateKey(DB, word)

            loop % history_field_array[word].Length() {
                search_result.Push(CopyObj(history_field_array[word, A_Index]))
            }
            ; 存在两个 ' 在词组中，比如 "wxhn" -> "wx"
            if( t:= InStr(word, "'", , , 2) )
            {
                ; Assert(0, "二字词: " . save_field_array[1, 0])
                word := SubStr(word,1,t-1)
                PinyinUpdateKey(DB, word)
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

PinyinResultInsertSingleWord(ByRef DB, ByRef search_result, srf_all_Input_tip)
{
    local
    global history_field_array
    first_word := SubStr(srf_all_Input_tip, 1, InStr(srf_all_Input_tip "'", "'")-1)
    if( first_word != srf_all_Input_tip )
    {
        PinyinUpdateKey(DB, first_word)
        loop % history_field_array[first_word].Length()
        {
            search_result.Push(CopyObj(history_field_array[first_word, A_Index]))
        }
    }
    return
}

PinyinResultHideZeroWeight(ByRef search_result)
{
    local
    if( search_result[1, 3]>0 )
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

PinyinResultRemoveZeroIndex(ByRef search_result)
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
    search_result           := []

    if( StrLen(ime_orgin_input) == 1 )
    {
        search_result[1] := [ime_orgin_input, ime_orgin_input, "-"]
        return search_result
    }
    else
    {
        ime_input_split_trim    := PinyinSplit(ime_orgin_input, "pinyin", 0, DB)
        ime_input_split_trim    := Trim(ime_input_split_trim, "'")
        ime_auxiliary_input     := ""   ; 辅助码

        ; ?
        PinyinProcess(DB, save_field_array, ime_input_split_trim, 10)

        ; 组词
        PinyinResultInsertCombine(DB, save_field_array, search_result, ime_auxiliary_input)
        ; 插入前面个拼音所能组成的候选词
        PinyinResultInsertWords(DB, save_field_array, search_result)

        ; 逐码提示 联想
        if( false ) {
            PinyinResultInsertAssociate(DB, search_result, ime_input_split_trim, ime_auxiliary_input)
        }
        ; 插入字部分
        PinyinResultInsertSingleWord(DB, search_result, ime_input_split_trim)


        ; 显示辅助码
        if( false ) {
            PinyinResultShowAuxiliary(search_result)
        }

        ; 辅助码或超级简拼
        if( false ) {
            ; 使用任意一或二位辅助码协助筛选候选项去除重码
            PinyinResultCheckAuxiliary(search_result, ime_auxiliary_input)
        } else {
            ; 超级简拼 显示 4~8 字简拼候选
            ; "woxihuanni" -> "w'o'x'i'h'u'a'n'n'i"
            separate_single_char := Trim(RegExReplace(ime_orgin_input,"(.)","$1'"), "'")
            if( ime_orgin_input~="^[^']{4,8}$" && ime_input_split_trim != separate_single_char )
            {
                PinyinResultInsertSimpleSpell(DB, search_result, separate_single_char)
            }
        }

        ; 隐藏词频低于 0 的词条，仅在无其他候选项的时候出现
        PinyinResultHideZeroWeight(search_result)


        PinyinResultRemoveZeroIndex(search_result)
    }
    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    return search_result
}
