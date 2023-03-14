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

PinyinProcess2(ByRef DB, ByRef save_field_array, ByRef search_result, tfzm)
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

    if( (save_field_array.Length()==1) || (tfzm) )
    {
        search_result := CopyObj(save_field_array[1])
    }
    else
    {
        if( save_field_array[2,1,1]!=Chr(2) )
        {
            ci := save_field_array[1,1,-1] "'" save_field_array[2,1,-1]
            While( InStr(ci,"'") && !PinyinHasResult(ci) ) {
                ci:=RegExReplace(ci, "i)'([^']+)?$")
            }
            if( ci~="^" save_field_array[1, 0] "'[a-z;]+" ){
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
        search_result.InsertAt(1, firstzhuju(save_field_array))
        search_result[1, 0] := "pinyin"
    }
    return
}

PinyinProcess3(ByRef DB, ByRef save_field_array, ByRef search_result)
{
    local
    global history_field_array
    scheme := "pinyin"
    ; 插入候选词部分
    if( ci:=RegExReplace(save_field_array[1,1,-1], "i)'[^']+$") )
    {
        While( InStr(ci,"'") && !PinyinHasResult(ci) )
        {
            if( !PinyinHasKey(ci) )
            {
                history_field_array[ci] := Get_jianpin(DB, scheme, "'" ci "'", "", 0, 0)
                if( PinyinHasResult(ci) ){
                    break
                }
            }
            ci:=RegExReplace(ci, "i)'([^']+)?$")
        }
        if( InStr(ci,"'") )
        {
            if( history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="" ){
                history_field_array[ci] := Get_jianpin(DB, scheme, "'" ci "'", "", 0, 0)
            }
            loop % history_field_array[ci].Length() {
                search_result.Push(CopyObj(history_field_array[ci, A_Index]))
            }
            ; 二字词
            if( t:= InStr(ci, "'", , , 2) )
            {
                ci := SubStr(ci,1,t-1)
                if( !PinyinHasKey(ci) || history_field_array[ci].Length()==2 && history_field_array[ci,2,2]=="" ){
                    history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", "", 0, 0)
                }
                if( PinyinHasResult(ci) ){
                    loop % history_field_array[ci].Length(){
                        search_result.Push(CopyObj(history_field_array[ci, A_Index]))
                    }
                }
            }
        }
    }
    return
}

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

PinyinProcess7(ByRef DB, ByRef search_result, srf_all_Input, dwselect, tfzm, fzm, chaojijp)
{
    global history_field_array
    jichu_for_select_Array := []
    scheme := "pinyin"

    if( tfzm )
    {
        saixuan:=[]
        loop % search_result.Length() {
            if (StrLen(search_result[A_Index,2])>1&&search_result[A_Index,6]~="i)" RegExReplace(tfzm,"(.)","$1(.*)?"))||(search_result[A_Index,6]~="i)^" tfzm)
                search_result[A_Index, -2]:=dwselect?tfzm:search_result[A_Index,6], saixuan.Push(search_result[A_Index])
            else
                search_result[A_Index].Delete(-2)
        }
        if( saixuan.Length() ){
            search_result:=saixuan
        } else {
            tfzm:=""
        }
    }
    else
    {
        single_char_spell := Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'")
        if( chaojijp && (srf_all_Input~="^[^']{4,8}$") && !PinyinHasKey(single_char_spell) ){
            history_field_array[single_char_spell] := Get_jianpin(DB, scheme, "'" single_char_spell "'", "", 0, 8, true)
        }
        if( single_char_spell ){
            loop % list_len := history_field_array[single_char_spell].Length() {
                search_result.InsertAt(1, CopyObj(history_field_array[single_char_spell, list_len+1-A_Index]))
            }
        }
        if( fzm=="" ){
            loop % jichu_for_select_Array.Length()
                jichu_for_select_Array[A_Index].Delete(-2)
        }
        ; 云输入, 2字词以上触发
        ; if( CloudInput && inspos==2 && InStr(srf_all_Input_py, "'", , 1, 2)){
        ;     ; search_result.InsertAt(2,{0:"<Cloud>|-1",1:"",2:""})
        ;     SetTimer, BDCloudInput, -10
        ; }
    }
    return

    ; 云输入
    BDCloudInput:
        if( srf_all_Input_py=""||InStr(srf_all_Input_tip,"\") ){
            return 0
        }
        ; BDCloudInput(srf_all_Input_py)
        CloudinputApi.get(srf_all_Input_py)
    return 0
}

PinyinProcess8(ByRef search_result, hide_zero_weight)
{
    local
    if( hide_zero_weight && search_result[1, 3]>0 )
    {
        loop % len := search_result.Length() {
            if( search_result[len+1-A_Index, 3] && search_result[len+1-A_Index, 3]<=0 )
                search_result.RemoveAt(len+1-A_Index)
        }
    }
    return
}

PinyinProcess9(ByRef search_result)
{
    ; Assert(!search_result.HasKey(0))
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

    scheme := "pinyin"
    srf_all_Input_for_trim  := Trim(PinyinSplit(ime_orgin_input, scheme, 0, DB), "'")
    srf_all_Input_tip       := srf_all_Input_for_trim
    
    full_pinyin             := PinyinSplit(srf_all_Input_for_trim, scheme, 1)
    srf_all_Input_py        := srf_all_Input_for_trim ; Trim(RegExReplace(full_pinyin,"'?\\'?"," "), "'")
    srf_all_Input_for_trim  := StrReplace(srf_all_Input_for_trim,"\",Chr(2))

    search_result := []
    tfzm := ""

    ; ?
    PinyinProcess1(DB, save_field_array, srf_all_Input_for_trim, ime_orgin_input, 10)

    ; ?
    PinyinProcess2(DB, save_field_array, search_result, tfzm)
    ; ?
    PinyinProcess3(DB, save_field_array, search_result)

    ; 逐码提示 联想
    PinyinProcess4(DB, search_result, srf_all_Input_tip, srf_all_Input_py, tfzm, "", 0)
    ; 插入字部分
    PinyinProcess5(DB, search_result, srf_all_Input_tip)


    ; 使用任意一或二位辅助码协助筛选候选项去除重码
    PinyinProcess6(search_result, 0)
    ; 超级简拼 显示 4~8 字简拼候选
    PinyinProcess7(DB, search_result, ime_orgin_input, 0, tfzm, "", 1)
    ; 隐藏词频低于0的词条，仅在无其他候选项的时候出现
    PinyinProcess8(search_result, 0)
    ; ??
    PinyinProcess9(search_result)

    ; [
    ;     ; -1 , 0         , 1
    ;     ["wo", "pinyin|1", "wo", "我", "30233", "30233"]
    ;     ["wo", "pinyin|2", "wo", "窝", "30219", "30233"]
    ;     ...
    ; ]
    return search_result
}
