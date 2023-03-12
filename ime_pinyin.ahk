; 拼音取词
PinyinGetSentences(input, scheme:="pinyin"){
    local
    global srf_all_Input_, DB, fzm, Inputscheme, fuzhuma, history_field_array, save_field_array, chaojijp, imagine
    , DebugLevel, Singleword, mhyRegExObj, CloudInput, jichu_for_select_Array, srf_all_Input, tfzm, dwselect
    , insertpos, Useless, CloudinputApi
    
    Loop_num:=0
    history_cutpos:=[0]
    index:=0
    zisu:=10
    estr:=input
    begin:=A_TickCount

    if (input~="[A-Z]"){
        input:=Trim(StrReplace(RegExReplace(input,"([A-Z])","'$1'"),"''","'"),"'")
    }
    srf_all_Input_["tip"] := srf_all_Input_for_trim := Trim(PinyinSplit(input, scheme, 0, DB), "'")
    fzm := ""
    
    srf_all_Input_["py"] := Trim(RegExReplace(PinyinSplit(srf_all_Input_for_trim, scheme, 1),"'?\\'?"," "), "'")
    srf_all_Input_for_trim := StrReplace(srf_all_Input_for_trim,"\",Chr(2))

    if (1 ){
        ; 正向最大划分
        loop % save_field_array.Length()
        {
            if save_field_array[A_Index,0]=Chr(1)
                continue
            if (save_field_array[A_Index,0]=""){
                index:=A_Index
                break
            }
            checkstr .= save_field_array[A_Index,0] "'"
            if InStr("^" srf_all_Input_for_trim "'", "^" checkstr){
                t:=StrSplit(save_field_array[A_Index,0],"'").Length()
                ; 奇偶词条高权重优先
                ; if ((t>2)&&(Mod(t, 2)=1)&&(StrLen(checkstr)<StrLen(srf_all_Input_for_trim))&&(history_field_array[save_field_array[A_Index,0], 1, 3]<history_field_array[RegExReplace(save_field_array[A_Index,0],"'[a-z;]+$"), 1, 3])){
                ;     index:=A_Index
                ;     break
                ; }
                history_cutpos.Push(StrLen(checkstr))
            } else {
                index:=A_Index
                break
            }
        }
        if (index)
            save_field_array.RemoveAt(index, save_field_array.Length()-index+1)

        srf_all_Input_for_trim_len:=StrLen(srf_all_Input_for_trim)
        if (save_field_array.Length()>0){
            if history_cutpos.Length()>1&&SubStr(srf_all_Input_for_trim,history_cutpos[history_cutpos.Length()],1)!="'"
                history_cutpos.Pop(), save_field_array.Pop()
            begin:=A_TickCount
            loop % history_cutpos.Length()
            {
                if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
                    OutputDebug("Backtrack timeout", DebugLevel)
                    break
                }
                if ((srf_all_Input_trim_off:=SubStr(srf_all_Input_for_trim,history_cutpos[A_Index]+1))="")
                    break
                if InStr(srf_all_Input_trim_off, "'", , 1, zisu)
                    continue
                if !history_field_array.HasKey(srf_all_Input_trim_off){
                    history_field_array[srf_all_Input_trim_off]:= Get_jianpin(DB, scheme, "'" srf_all_Input_trim_off "'", mhyRegExObj, 0, A_Index=1?0:1)
                    if (history_field_array[srf_all_Input_trim_off, 1, 2]=""){
                        if !InStr(srf_all_Input_trim_off, "'")
                            history_field_array[srf_all_Input_trim_off]:={0:srf_all_Input_trim_off,1:[srf_all_Input_trim_off,srf_all_Input_trim_off=Chr(2)?"":srf_all_Input_trim_off]}
                        continue
                    } else if (A_Index>1)
                        history_field_array[srf_all_Input_trim_off].Push("")
                }
                if (history_field_array[srf_all_Input_trim_off, 1, 2]){
                    tarr:={}, Ln:=A_Index-1
                    loop % Ln
                        if save_field_array[A_Index, 0]
                            tarr.Push(save_field_array[A_Index])
                    tarr.Push(CopyObj(history_field_array[srf_all_Input_trim_off]))
                    save_field_array:=tarr, tarr:="", history_cutpos:=[0]
                    loop % save_field_array.Length()
                        history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
                }
            }
        }
        if (tpos:=history_cutpos[history_cutpos.Length()])<srf_all_Input_for_trim_len
        {
            Loop_num:=0, begin:=A_TickCount
            loop
            {
                if (A_TickCount - begin > 50 && !Mod(A_Index, 20)){
                    OutputDebug("Forward timeout", DebugLevel)
                    break
                }
                if ((cutpos:=InStr(srf_all_Input_for_trim "'", "'", 0, 0, Loop_num+=1))<tpos+1)
                    ||((srf_Input_trim_left:=SubStr(srf_all_Input_for_trim,tpos+1,cutpos-1-tpos))="")
                    break
                if InStr(srf_Input_trim_left, "'", , 1, zisu)
                    continue
                srf_Input_trim_right:=SubStr(srf_all_Input_for_trim,cutpos+1)
                if srf_Input_trim_left&&!history_field_array.HasKey(srf_Input_trim_left){
                    history_field_array[srf_Input_trim_left]:= Get_jianpin(DB, scheme, "'" srf_Input_trim_left "'", mhyRegExObj, 0, (tpos?1:0), ((scheme="pinyin")&&(!InStr(srf_all_Input,srf_Input_trim_left))))
                    ; jichu_for_select:= Get_jianpin(DB, scheme, "'" srf_Input_trim_left "'", , mhyRegExObj, (srf_Input_trim_right?0:1)&&(imagine?1:0), 0, ((scheme="pinyin")&&(!InStr(srf_all_Input,srf_Input_trim_left))))
                    if (history_field_array[srf_Input_trim_left, 1, 2]=""){
                        if InStr(srf_Input_trim_left,"'")
                            history_field_array[srf_Input_trim_left]:={0:srf_Input_trim_left}
                        else
                            history_field_array[srf_Input_trim_left]:={0:srf_Input_trim_left,1:[srf_Input_trim_left,srf_Input_trim_left=Chr(2)?"":srf_Input_trim_left]}
                    } else if (tpos)
                        history_field_array[srf_Input_trim_left].Push([])
                }
                if history_field_array[srf_Input_trim_left, 1, 2]=""&&InStr(srf_Input_trim_left,"'")
                    continue
                else {
                    t:=StrSplit(srf_Input_trim_left,"'").Length()
                    ; 奇偶词条高权重优先
                    ; if ((t>2)&&(Mod(t, 2)=1)&&srf_Input_trim_right&&(history_field_array[srf_Input_trim_left, 1, 3]<history_field_array[RegExReplace(srf_Input_trim_left,"'[a-z;]+$"), 1, 3]))
                    ;     continue
                    Loop_num:=0
                    if (srf_Input_trim_left!="")
                        save_field_array.Push(CopyObj(history_field_array[srf_Input_trim_left])), history_cutpos[history_cutpos.Length()+1]:=history_cutpos[history_cutpos.Length()]+1+StrLen(srf_Input_trim_left)
                    ; history_cutpos:=[0]
                    ; loop % save_field_array.Length()
                    ;     history_cutpos[A_Index+1]:=history_cutpos[A_Index]+StrLen(save_field_array[A_Index,0])+1
                    tpos:=history_cutpos[history_cutpos.Length()]
                }
            }
        }
    }
    jichu_for_select:=""
    search_result:=[]
    if (save_field_array[1].Length()=2&&save_field_array[1,2,2]="")
        save_field_array[1]:=CopyObj(history_field_array[save_field_array[1,0]]:= Get_jianpin(DB, scheme, "'" save_field_array[1,0] "'", mhyRegExObj, 0, 0))
    if (save_field_array.Length()=1)||(tfzm){
        ; search_result:=save_field_array[1]
        search_result:=CopyObj(save_field_array[1])
    } else {
        if (save_field_array[2,1,1]!=Chr(2)){
            ci:=save_field_array[1,1,-1] "'" save_field_array[2,1,-1]
            While (InStr(ci,"'")&&(history_field_array[ci, 1, 2]=""))
                ci:=RegExReplace(ci, "i)'([^']+)?$")
            if (ci~="^" save_field_array[1, 0] "'[a-z;]+"){
                if (history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
                    history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
                search_result:=CopyObj(history_field_array[ci])
            }
        }
        if InStr(save_field_array[1, 0], "'")
            loop % save_field_array[1].Length()
                ; search_result.Push(save_field_array[1, A_Index])
                search_result.Push(CopyObj(save_field_array[1, A_Index]))
        search_result.InsertAt(1, firstzhuju(save_field_array)), search_result[1, 0]:="pinyin"
    }

    ; 插入候选词部分
    if (ci:=RegExReplace(save_field_array[1,1,-1], "i)'[^']+$")){
        While InStr(ci,"'")&&(history_field_array[ci, 1, 2]=""){
            if (!history_field_array.HasKey(ci)){
                history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
                if (history_field_array[ci, 1, 2])
                    break
            }
            ci:=RegExReplace(ci, "i)'([^']+)?$")
        }
        if InStr(ci,"'"){
            if (history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
                history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
            loop % history_field_array[ci].Length()
                search_result.Push(CopyObj(history_field_array[ci, A_Index]))
            ; 二字词
            if (t:=InStr(ci, "'", , , 2)){
                ci:=SubStr(ci,1,t-1)
                if (!history_field_array.HasKey(ci)||history_field_array[ci].Length()=2&&history_field_array[ci,2,2]="")
                    history_field_array[ci]:= Get_jianpin(DB, scheme, "'" ci "'", mhyRegExObj, 0, 0)
                if (history_field_array[ci, 1, 2]!="")
                    loop % history_field_array[ci].Length()
                        search_result.Push(CopyObj(history_field_array[ci, A_Index]))
                }
            }
        }
    if !(tfzm||StrLen(fzm)=1)
        && (imagine&&InStr(srf_all_Input_["py"], "'", , 1, 3)){
        if (history_field_array[srf_all_Input_["tip"], -1]=""){
            history_field_array[srf_all_Input_["tip"], -1]:=Get_jianpin(DB, "", "'" srf_all_Input_["py"] "'", mhyRegExObj, 1, 0)
        }
        loop % tt:=history_field_array[srf_all_Input_["tip"], -1].Length()
            search_result.InsertAt(2, CopyObj(history_field_array[srf_all_Input_["tip"], -1, tt+1-A_Index]))
    }
    if (StrLen(fzm)=2&&SubStr(srf_all_Input_["tip"],-2,1)="'"){
        inspos:=2    ;, inspos:=search_result.Length()+1
        ; loop % tt:=saixuan.Length()
        ; search_result.InsertAt(inspos,saixuan[tt+1-A_Index])    ; 词组优先
    } else {
        loop % tt:=saixuan.Length()
            search_result.InsertAt(1,saixuan[tt+1-A_Index])    ; 辅助词条优先
        inspos:=tt?1:2
    }
    ; 插入候选字部分
    ; if InStr(save_field_array[1, 0], "'"){
    zi:=SubStr(srf_all_Input_["tip"] ,1, InStr(srf_all_Input_["tip"] "'", "'")-1)
    if !(history_field_array.HasKey(zi))||(history_field_array[zi].Length()=2&&history_field_array[zi,2,2]="")
        history_field_array[zi]:= Get_jianpin(DB, scheme, "'" zi "'", mhyRegExObj, 0, 0)
    loop % history_field_array[zi].Length()
        search_result.Push(CopyObj(history_field_array[zi, A_Index]))
    ; }
    ; if fuzhuma&&(((Inputscheme~="sp$")&&(srf_all_Input_["tip"]~="'[a-z][a-z]'$"))||((Inputscheme="pinyin")&&(srf_all_Input_["tip"]~="[a-z][aoeiuvng]'$"))){
    if (fuzhuma){
        loop % search_result.Length()
            if InStr(search_result[A_Index, 0], "pinyin|")&&(search_result[A_Index, 6]="")
                search_result[A_Index, 6]:=fzmfancha(search_result[A_Index, 2])
        }
    if (tfzm){
        saixuan:=[]
        loop % search_result.Length(){
            if (StrLen(search_result[A_Index,2])>1&&search_result[A_Index,6]~="i)" RegExReplace(tfzm,"(.)","$1(.*)?"))||(search_result[A_Index,6]~="i)^" tfzm)
                search_result[A_Index, -2]:=dwselect?tfzm:search_result[A_Index,6], saixuan.Push(search_result[A_Index])
            else
                search_result[A_Index].Delete(-2)
        }
        if saixuan.Length()
            search_result:=saixuan
        else
            tfzm:=""
    } else {
        if chaojijp&&(srf_all_Input~="^[^']{4,8}$")&&!history_field_array.HasKey(cjjp:=Trim(RegExReplace(srf_all_Input,"(.)","$1'"), "'"))
            history_field_array[cjjp]:= Get_jianpin(DB, scheme, "'" cjjp "'", mhyRegExObj, 0, 8, true)
        if (cjjp)
            loop % l:=history_field_array[cjjp].Length()
                search_result.InsertAt(2,CopyObj(history_field_array[cjjp,l+1-A_Index]))
        if (fzm=""){
            loop % jichu_for_select_Array.Length()
                jichu_for_select_Array[A_Index].Delete(-2)
        }
        ; 云输入, 2字词以上触发
        if CloudInput&&inspos=2&&InStr(srf_all_Input_["py"], "'", , 1, 2){
            ; search_result.InsertAt(2,{0:"<Cloud>|-1",1:"",2:""})
            SetTimer, BDCloudInput, -10
        }
    }
    if (Useless&&search_result[1, 3]>0){
        loop % len:=search_result.Length()
            if (search_result[len+1-A_Index, 3]&&search_result[len+1-A_Index, 3]<=0)
                search_result.RemoveAt(len+1-A_Index)
        }
    if (search_result.HasKey(0))
        search_result.Delete(0)
    return search_result
    ; 云输入
    BDCloudInput:
        if (srf_all_Input_["py"]=""||InStr(srf_all_Input_["tip"],"\"))
            return 0
        ; BDCloudInput(srf_all_Input_["py"])
        CloudinputApi.get(srf_all_Input_["py"])
    return 0
}

PinyinInit()
{
    local
    global JSON
    global pinyin_table
    static lsm:=["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou"]
    ; 全拼声母韵母表    add "din"、"tin"、""、""
    quanpinbiao =
    (LTrim
        {"i" :{"1":"i"},"u" :{"1":"u"},"v" :{"1":"v"},"a" :{"1":"a","ai":"i","an":"n","ang":"ng","ao":"o"}
        ,"b" :{"1":"b","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","u":"u","un":"un"}
        ,"c" :{"1":"c", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"ch":{"1":"ch","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
        ,"d" :{"1":"d","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"e" :{"1":"e","ei":"i","en":"n","eng":"ng","er":"r"}
        ,"f" :{"1":"f","a":"a","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","iao":"iao","o":"o","ou":"ou","u":"u"}
        ,"g" :{"1":"g","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
        ,"h" :{"1":"h","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
        ,"j" :{"1":"j","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"}
        ,"k" :{"1":"k","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","ei":"ei","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
        ,"l" :{"1":"l","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","un":"un","uo":"uo","ve":"ue"}
        ,"m" :{"1":"m","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","o":"o","ou":"ou","u":"u"}
        ,"n" :{"1":"n","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","uo":"uo","un":"un","ve":"ue"}
        ,"o" :{"1":"o","ou":"u"}
        ,"p" :{"1":"p","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","ou":"ou","u":"u"}
        ,"q" :{"1":"q","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","van":"uan","ve":"ue","vn":"un","v":"u"}
        ,"r" :{"1":"r","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"s" :{"1":"s", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"sh":{"1":"sh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"}
        ,"t" :{"1":"t","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","eng":"eng","ei":"ei","i":"i","ian":"ian","iao":"iao","ie":"ie","ing":"ing","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"w" :{"1":"w","a":"a","ai":"ai","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","o":"o","u":"u"}
        ,"x" :{"1":"x","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","un":"un","ue":"ue","van":"uan","ve":"ue","vn":"un","v":"u"}
        ,"y" :{"1":"y","a":"a","an":"an","ang":"ang","ao":"ao","e":"e","i":"i","in":"in","ing":"ing","o":"o","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"}
        ,"z" :{"1":"z", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"}
        ,"zh":{"1":"zh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uang":"uang"}}
    )
    qpb:=JSON.Load(quanpinbiao)
    pinyin_table:=qpb, pinyin_table["l","ue"]:="ue", pinyin_table["n","ue"]:="ue"
    For key,value In lsm
    {
        if (StrLen(value)>1){
            pinyin_table[t1:=SubStr(value, 1, 1)].Delete(value)
            pinyin_table[t1][t2:=SubStr(value, 2)]:=t2
        }
    }
}

; 拼音音节切分
PinyinSplit(str, pinyintype:="pinyin", show_full:=0, DB:="")
{
    local
    Critical
    static lsmmd := ""
    static vowels_max_test_len := 4
    static lsm := ["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou"]    ; 零声母
    global pinyin_table

    index := 1
    separate_words := "'"
    strlen := StrLen(str)
    lastchar := " "
    loop
    {
        initials:=SubStr(str, index, 1)
        ; 如果是数字
        if (pinyin_table[initials,""] initials~="\d"){
            ; separate_words := RTrim(separate_words,"'") . (show_full&&pinyin_table[initials,""]?pinyin_table[initials,""]:initials) . "'"
            index += 1
            continue
        } else if pinyin_table.HasKey(initials)
        {
            ; 声母
            index += 1
            if (InStr("csz", initials)&&(SubStr(str, index, 1)="h")) {
                ; zcs + h
                index+=1
                initials .= "h"
            }

            ; 韵母
            vowels := ""
            vowels_len := 0
            loop
            {
                if (index+vowels_max_test_len-A_Index>strlen) {
                    continue
                }
                vowels_len := vowels_max_test_len+1-A_Index
                vowels := SubStr(str, index, vowels_len)
                if (pinyin_table[initials][vowels]) {
                    break
                }
                if (A_Index >= vowels_max_test_len+1) {
                    break
                }
            }

            ; 词库辅助分词
            if ((InStr("n|g", lastchar)||(lastchar="e"&&initials="r"))&&(!vowels||InStr("aeo", initials))){
                if (pinyin_table[ttsm][SubStr(ttym,1,-1)])
                {
                    tfc:=LTrim(PinyinSplit(SubStr(str,index-2)),"'")
                    if (InStr(tfc, "'")>2){
                        if (CheckPinyinSplit(DB,SubStr(separate_words,1,-2) "'" tfc)>=CheckPinyinSplit(DB,separate_words initials vowels "'"))
                            return (SubStr(separate_words,0)="'"?SubStr(separate_words,1,-2):SubStr(separate_words,1,-1)) "'" tfc
                    }
                }
            }

            ; 转全拼显示
            if (show_full)
                ttym:=vowels,ttsm:=initials,separate_words .= pinyin_table[initials][1] . pinyin_table[initials][vowels] "'"
            else
                ttym:=vowels,ttsm:=initials,separate_words .= initials vowels "'"

            index += vowels_len
            if( pinyin_table[initials][vowels] ){
                lastchar := SubStr(pinyin_table[initials][vowels],0)
            } else if( pinyin_table[initials][1] ) {
                lastchar := SubStr(pinyin_table[initials][1],0)
            }
        } 
        else {
            index+=1, lastchar:=initials
            if (initials!="'")
                separate_words .= initials "'"
        }
    } until index>strlen
    return separate_words
}

Get_jianpin(DB,scheme,str,RegExObj:="",lianxiang:=1,LimitNum:=100,cjjp:=false){
    local
    Critical
    global SQL_buffer, customspjm
    cpfg:=0, ystr:=Trim(str, "'")
    if (scheme)
        str:=PinyinSplit(str,scheme,1)
    str:=StrReplace(str, "'", "''"), str:=StrReplace(str, "on'", "ong'"), tstr:=Trim(RegExReplace(str, "([a-z]h?)[a-gi-z]+", "$1", nCount), "'")
    tstr:=RegExReplace(tstr, "([csz])h", "$1")
    if (nCount){
        rstr:=RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
        loop % RegExObj.Length()
            rstr:=RegExReplace(rstr, RegExObj[A_Index,1], RegExObj[A_Index,2])
    } else if (scheme="pinyin"){
        tRegEx:=""
        For _,key In ["c","s","z"]
            if InStr(str,key "h")&&!InStr(RegExObj[1,1],key)
                tRegEx .= key
        if (tRegEx){
            rstr:=RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
            if (StrLen(tstr)=1)
                LimitNum:=100
        }
    } else {
        tRegEx:=""
        For _,key In ["c","s","z"]
            if InStr(str,key)&&!InStr(RegExObj[1,1],key)
                tRegEx .= key
        if (tRegEx){
            rstr:=RegExReplace(str, "'([" tRegEx "]h?)'", "'$1[^h]*'")
            if (ystr~="[aoe]{2}")
                rstr:=RegExReplace(rstr, "'([^aoe]h?)'", "'$1[a-z]*'")
            else
                rstr:=RegExReplace(rstr, "'([a-z]h?)'", "'$1[a-z]*'")
            if (StrLen(tstr)=1)
                LimitNum:=100
        }
    }
    if (rstr="")
        if (str~="^''[aoe](''[aoe])*''$")
            rstr:=str
        else
            LimitNum:=100
    rstr:=Trim(rstr,"'"), lsm:="o"
    if (cpfg:=lianxiang){
        if (rstr~="[\.\*\?\|\[\]]")
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{' AND key REGEXP '^" rstr "' ORDER BY weight DESC LIMIT 3"
        else
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{'" (rstr?" AND key>='" rstr "''a' AND key<'" rstr "''{'":"") " ORDER BY weight DESC LIMIT 3"
    } else if (cjjp&&(scheme~="i)^(abc|wr|sg)sp"||(lsm:=customspjm[scheme, "0"])~="^[a-zA-Z]$")&&InStr(str, lsm)){
        tstr:=StrReplace(tstr, lsm, "_", nCount:=0), rstr:=StrReplace(tstr, "_", "[aoe]")
        if (nCount>4 )
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE " Format("((jp>='{:s}a' AND jp<'{:s}b') OR (jp>='{:s}e' AND jp<'{:s}f') OR (jp>='{:s}o' AND jp<'{:s}p')) AND", SubStr(tstr, 1, InStr(tstr, "_")-1)) " jp like '" tstr "' AND jp REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
        else
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp IN " enumlsm(tstr) " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
    } else {
        if (rstr~="[\.\*\?\|\[\]]")
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp='" tstr "' AND key REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
        else
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp='" tstr "'" (rstr?" AND key='" rstr "'":"") " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
    }
    if DB.GetTable(_SQL,Result){
        if (Result.RowCount){
            if (cpfg){

            } else {
                loop % Result.RowCount
                    Result.Rows[A_Index, -1]:=ystr, Result.Rows[A_Index, 0]:="pinyin|" A_Index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3]
                ; Result.Rows[1, 0]:="pinyin|0"
            }
            SQL_buffer[ystr]:=_SQL
        }
        Result.Rows[0]:=ystr
        return Result.Rows        ; {1:[key1,value1],2:[key2,value2]...}
    } else
        return []
}

firstzhuju(arr){    ; 首选组词
    rarr:=["",""]
    loop % arr.Length()
        if (arr[A_Index, 0]!=Chr(2))
            rarr[1] .= (rarr[1]?"'":"") arr[A_Index, 1, 1], rarr[2] .= arr[A_Index, 1, 2]
    return rarr
}

; 模糊取词
get_word_lianxiang(DB, input, cikuname, num:=200, xz:=0){
    local
    Critical
    global Imagine, Singleword, SQL_buffer, srf_all_Input
    if (input="")
        return []
    if (cikuname="English"){
        len:=StrLen(input), _SQL:="SELECT '','" input "'||substr(key," len+1 "),weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '','" input "'||substr(key," len+1 "),weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' " (xz?"AND length(key)<" xz+StrLen(Input):"") " ORDER by 4,weight DESC " (num?" limit " num:"")
        ; if (Ord(input)<91)
        ;     _SQL:="SELECT '',upper(substr(key,1,1))||substr(key,2),weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '',upper(substr(key,1,1))||substr(key,2),weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' " (xz?"AND length(key)<5+" StrLen(Input):"") " ORDER by 4,weight DESC " (num?" limit " num:"")
        ; else
        ;     _SQL:="SELECT '',key,weight,1 FROM 'extend'.'English' WHERE key='" Input "' UNION ALL SELECT '',key,weight,2 FROM 'extend'.'English' WHERE key>'" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' AND length(key)<5+" StrLen(Input) " ORDER by 4,weight DESC " (num?" limit " num:"")
    } else if (cikuname="hotstrings"), Input:=Format("{:L}", Input)
        _SQL:="SELECT value,comment,replace(replace(value,x'0a','``n'),x'09','``t') FROM 'extend'.'hotstrings' WHERE key>='" Input "' AND key<""" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) """ AND value <> '' ORDER by key " (num?" limit 2":"")
    else if (cikuname="functions")
        _SQL:="SELECT value,comment,comment FROM 'extend'.'functions' WHERE key>='" Input "' AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "' AND value <> '' ORDER by key " (num?" limit 2":"")
    else
        word:=Singleword||InStr(srf_all_Input,"``"), _SQL:="SELECT key,value,weight,1 FROM '" cikuname "' WHERE key='" Input "' AND value <> '' " (word?"AND length(value)=1":"") " UNION ALL SELECT key,value,weight,length(key) FROM '" cikuname "' WHERE key>'" Input "' " ("AND key<'" SubStr(Input, 1, -1) Chr(Ord(SubStr(Input, 0))+1) "'") " AND length(key)<" StrLen(Input)+3 " AND value <> '' " (word?"AND length(value)=1":"") " ORDER by 4,weight DESC " (num?"limit " num:"")
    if DB.GetTable(_SQL, Result){
        if (Result.RowCount){
            if (cikuname="hotstrings"){
                loop % Result.RowCount {
                    if RegExMatch(Result.Rows[A_Index, 2], "\{.*\}", Match){
                        Result.Rows[A_Index, 2]:=StrReplace(Result.Rows[A_Index, 2],Match)
                        if InStr(Match,"{bz}")
                            Result.Rows[A_Index, 3]:=Result.Rows[A_Index, 2], Result.Rows[A_Index, 0]:=StrReplace(Match,"{bz}")
                        else
                            Result.Rows[A_Index, 0]:=Match
                    }
                    if (!InStr(Match,"{bz}")&&StrLen(Result.Rows[A_Index, 3])>30)
                        Result.Rows[A_Index, 3]:=SubStr(Result.Rows[A_Index, 3],1,30) "……"
                }
            } else if (cikuname="functions"){
                loop % Result.RowCount
                    if RegExMatch(Result.Rows[A_Index, 2], "\{.*\}", Match){
                        if ((Result.Rows[A_Index, 3]:=StrReplace(Result.Rows[A_Index, 2],Match))="")
                            Result.Rows[A_Index, 3]:=SubStr(StrReplace(Result.Rows[A_Index, 1],"`n","``n"),1,30) (StrLen(Result.Rows[A_Index, 1])>30?"……":"")
                        Result.Rows[A_Index, 0]:=Match
                    }
            } else if (cikuname="English"){
                loop % Result.RowCount
                    Result.Rows[A_Index, 3]:=Result.Rows[A_Index, 2]
            } else {
                index:=0, fg:=0, SQL_buffer[input]:=_SQL
                loop % Result.RowCount
                    if (Result.Rows[A_Index, 4]=2){
                        if fg=0
                            fg:=A_Index, index:=0
                        index++, Result.Rows[A_Index, 0]:=cikuname "|" index, Result.Rows[A_Index, 4]:=Result.Rows[fg, 3], Result.Rows[A_Index, -1]:=input
                    } else
                        index++, Result.Rows[A_Index, 0]:=cikuname "|" index, Result.Rows[A_Index, 4]:=Result.Rows[1, 3], Result.Rows[A_Index, -1]:=input
                }
            }
        Result.Rows[0]:=input
        return Result.Rows
    }
    return []
}
fzmfancha(str){        ; 辅助码构成规则
    local
    global srf_fzm_fancha_table
    if (len:=StrLen(str))=1
        return srf_fzm_fancha_table[str]
    else if len>4
        return
    result:=""
    ; 每字第一码
    loop, Parse, str
        result .= SubStr(srf_fzm_fancha_table[A_LoopField], 1, 1)
    ; 词末字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,0,1)]
    ; 首字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,1,1)]
    return result
}

CheckPinyinSplit(DB, str){
    local
    static history:={0:0}
    if !DB
        return -1
    if (history[0]>500)
        history:={0:0}
    if (history[str]!="")
        return history[str]
    str:=StrReplace(str, "'", "''")
    tstr:=RegExReplace(Trim(str, "'"), "([a-z])[a-z]+", "$1")
    rstr:=RegExReplace(str, "'([csz]h?)'", "'$1.*'")
    _SQL:="SELECT weight FROM pinyin WHERE jp='" tstr "' AND key REGEXP '^" Trim(rstr,"'") "$' ORDER BY weight DESC LIMIT 1"
    if DB.GetTable(_SQL,Result){
        if (Result.Rows[1][1])
            return Result.Rows[1][1], history[str]:=Result.Rows[1][1], history[0]++
        else
            return 0, history[str]:=0, history[0]++
    } else
        return -1
}
enumlsm(str){
    local res, t
    res:=[""], t:=""
    loop, Parse, str
    {
        if (A_LoopField="_"){
            len:=res.Length()
            if (t!=""){
                loop % len
                    res[A_Index] .= t
                t:=""
            }
            loop % len {
                res.Push(res[A_Index] "e")
                res.Push(res[A_Index] "o")
                res[A_Index] .= "a"
            }
        } else {
            t .= A_LoopField
            continue
        }
    }
    str:=""
    loop % res.Length()
        res[A_Index]:=res[A_Index] t, str .= ",'" res[A_Index] "'"
    return "(" LTrim(str, ",") ")"
}