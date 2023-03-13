PinyinHasResult(pinyin)
{
    global history_field_array
    return history_field_array[pinyin, 1, 2] != ""
}

PinyinHasKey(pinyin)
{
    global history_field_array
    return history_field_array.HasKey(pinyin)
}

; 拼音取词
PinyinGetSentences(input, scheme:="pinyin")
{
    local
    global history_field_array
    global DB, fzm, fuzhuma, chaojijp, imagine, jichu_for_select_Array, tfzm, dwselect

    static save_field_array := []
    local srf_all_Input

    srf_all_Input := input
    ; Those variable should be used
    tfzm := ""
    imagine := 0    ; 逐码提示 联想
    fuzhuma := 0
    chaojijp := 0   ; 超级简拼 显示 4~8 字简拼候选
    jichu_for_select_Array := []
    Useless := 1    ; 隐藏词频低于0的词条，仅在无其他候选项的时候出现

    Loop_num        :=0
    history_cutpos  :=[0]
    index   :=0
    zisu    := 10
    estr    := input

    fzm := ""
    
    srf_all_Input_for_trim  := Trim(PinyinSplit(input, scheme, 0, DB), "'")
    srf_all_Input_tip       := srf_all_Input_for_trim
    
    full_pinyin             := PinyinSplit(srf_all_Input_for_trim, scheme, 1)
    srf_all_Input_py        := srf_all_Input_for_trim ; Trim(RegExReplace(full_pinyin,"'?\\'?"," "), "'")
    srf_all_Input_for_trim  := StrReplace(srf_all_Input_for_trim,"\",Chr(2))

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
                    history_field_array[srf_all_Input_trim_off] := Get_jianpin(DB, scheme, "'" srf_all_Input_trim_off "'", "", 0, A_Index=1?0:1)
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
            Loop_num:=0, begin := A_TickCount
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
                    limit_num :=  (test_pos?1:0)
                    cjjp := !InStr(srf_all_Input, srf_Input_trim_left)
                    history_field_array[srf_Input_trim_left] := Get_jianpin(DB, scheme, "'" srf_Input_trim_left "'", "", 0, limit_num, cjjp)

                    if( !PinyinHasResult(srf_Input_trim_left) )
                    {
                        if( InStr(srf_Input_trim_left,"'") ){
                            history_field_array[srf_Input_trim_left] := {0:srf_Input_trim_left}
                        } else {
                            CallStack()
                            history_field_array[srf_Input_trim_left] := {0:srf_Input_trim_left,1:[srf_Input_trim_left,srf_Input_trim_left=Chr(2)?"":srf_Input_trim_left]}
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
                    Loop_num:=0
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

    search_result := []
    if( save_field_array[1].Length()==2 && save_field_array[1,2,2]=="" )
    {
        sql_result := Get_jianpin(DB, scheme, "'" save_field_array[1,0] "'", "", 0, 0)
        history_field_array[save_field_array[1,0]] := sql_result
        save_field_array[1] := CopyObj(sql_result)
    }

    if( (save_field_array.Length()==1) || (tfzm) )
    {
        search_result:=CopyObj(save_field_array[1])
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
                search_result:=CopyObj(history_field_array[ci])
            }
        }

        if( InStr(save_field_array[1, 0], "'") ){
            loop % save_field_array[1].Length() {
                search_result.Push(CopyObj(save_field_array[1, A_Index]))
            }
        }
        search_result.InsertAt(1, firstzhuju(save_field_array)), search_result[1, 0]:="pinyin"
    }

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

    if( !(tfzm||StrLen(fzm)==1) && (imagine&&InStr(srf_all_Input_py, "'", , 1, 3)))
    {
        if( history_field_array[srf_all_Input_tip, -1]==="" ){
            history_field_array[srf_all_Input_tip, -1] := Get_jianpin(DB, "", "'" srf_all_Input_py "'", "", 1, 0)
        }
        loop % tt:=history_field_array[srf_all_Input_tip, -1].Length() {
            search_result.InsertAt(2, CopyObj(history_field_array[srf_all_Input_tip, -1, tt+1-A_Index]))
        }
    }

    if( StrLen(fzm)=2&&SubStr(srf_all_Input_tip,-2,1)=="'" ){
        inspos:=2    ;, inspos:=search_result.Length()+1
        ; loop % tt:=saixuan.Length()
        ; search_result.InsertAt(inspos,saixuan[tt+1-A_Index])    ; 词组优先
    } else {
        ; loop % tt:=saixuan.Length()
        ;     search_result.InsertAt(1,saixuan[tt+1-A_Index])    ; 辅助词条优先
        ; inspos:=tt?1:2
        inspos:=1
    }

    ; 插入字部分
    first_word := SubStr(srf_all_Input_tip, 1, InStr(srf_all_Input_tip "'", "'")-1)
    if( first_word != input )
    {
        if( !PinyinHasKey(first_word) || (history_field_array[first_word].Length()==2 && history_field_array[first_word,2,2]=="") )
        {
            history_field_array[first_word]:= Get_jianpin(DB, scheme, "'" first_word "'", "", 0, 0)
        }
        loop % history_field_array[first_word].Length()
        {
            search_result.Push(CopyObj(history_field_array[first_word, A_Index]))
        }
    }

    if( fuzhuma )
    {
        loop % search_result.Length() {
            if( InStr(search_result[A_Index, 0], "pinyin|") && (search_result[A_Index, 6]=="") ){
                search_result[A_Index, 6]:=fzmfancha(search_result[A_Index, 2])
            }
        }
    }

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
        cjjp := Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'")
        if( chaojijp && (srf_all_Input~="^[^']{4,8}$") && !PinyinHasKey(cjjp) ){
            history_field_array[cjjp]:= Get_jianpin(DB, scheme, "'" cjjp "'", "", 0, 8, true)
        }
        if( cjjp ){
            loop % l:=history_field_array[cjjp].Length()
                search_result.InsertAt(2,CopyObj(history_field_array[cjjp,l+1-A_Index]))
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

    if( Useless && search_result[1, 3]>0 ){
        loop % len:=search_result.Length() {
            if( search_result[len+1-A_Index, 3] && search_result[len+1-A_Index, 3]<=0 )
                search_result.RemoveAt(len+1-A_Index)
        }
    }

    if (search_result.HasKey(0)) {
        search_result.Delete(0)
    }

    return search_result

    ; 云输入
    BDCloudInput:
        if (srf_all_Input_py=""||InStr(srf_all_Input_tip,"\"))
            return 0
        ; BDCloudInput(srf_all_Input_py)
        CloudinputApi.get(srf_all_Input_py)
    return 0
}
