PinyinInit()
{
    local
    global JSON
    global pinyin_table

    ; 零声母
    global zero_initials_table := ["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou"]

    ; 全拼声母韵母表
    full_spelling_json =
    (LTrim
        {
            "a" :{"1":"a","ai":"i","an":"n","ang":"ng","ao":"o"},
            "e" :{"1":"e","ei":"i","en":"n","eng":"ng","er":"r"},
            "o" :{"1":"o","ou":"u"},
            "i" :{"1":"i"},
            "u" :{"1":"u"},
            "v" :{"1":"v"},

            "b" :{"1":"b","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","u":"u","un":"un"},
            "p" :{"1":"p","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","ou":"ou","u":"u"},
            "m" :{"1":"m","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","o":"o","ou":"ou","u":"u"},
            "f" :{"1":"f","a":"a","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","iao":"iao","o":"o","ou":"ou","u":"u"},

            "d" :{"1":"d","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "t" :{"1":"t","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","eng":"eng","ei":"ei","i":"i","ian":"ian","iao":"iao","ie":"ie","ing":"ing","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "n" :{"1":"n","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","uo":"uo","un":"un","ve":"ue"},
            "l" :{"1":"l","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","un":"un","uo":"uo","ve":"ue"},

            "g" :{"1":"g","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "k" :{"1":"k","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","ei":"ei","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "h" :{"1":"h","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},

            "j" :{"1":"j","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"},
            "q" :{"1":"q","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","van":"uan","ve":"ue","vn":"un","v":"u"},
            "x" :{"1":"x","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","un":"un","ue":"ue","van":"uan","ve":"ue","vn":"un","v":"u"},

            "zh":{"1":"zh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uang":"uang"},
            "ch":{"1":"ch","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "sh":{"1":"sh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "r" :{"1":"r","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},

            "z" :{"1":"z", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "c" :{"1":"c", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "s" :{"1":"s", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},

            "y" :{"1":"y","a":"a","an":"an","ang":"ang","ao":"ao","e":"e","i":"i","in":"in","ing":"ing","o":"o","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"},
            "w" :{"1":"w","a":"a","ai":"ai","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","o":"o","u":"u"}
        }
    )

    pinyin_table := JSON.Load(full_spelling_json)
    pinyin_table["l","ue"] := "ue"
    pinyin_table["n","ue"] := "ue"

    for key,value In zero_initials_table
    {
        if (StrLen(value)>1)
        {
            pinyin_table[t1:=SubStr(value, 1, 1)].Delete(value)
            pinyin_table[t1][t2:=SubStr(value, 2)]:=t2
        }
    }
}

; 拼音音节切分
; ' 表示自动分词
; 12345 空格 大写 表示手动分词
PinyinSplit(str, pinyintype:="pinyin", show_full:=0, DB:="")
{
    local
    Critical
    global pinyin_table

    index := 1
    separate_words := ""
    strlen := StrLen(str)
    last_char := "'"

    loop
    {
        if( index > strlen ) {
            break
        }

        initials := SubStr(str, index, 1)
        ; 数字，强制分词
        if( initials ~= "\d" || initials == " ")
        {
            separate_words := RTrim(separate_words,"'") . initials
            index += 1
            last_char := "'"
            continue
        }
        ; 字母，自动分词
        else if( pinyin_table.HasKey(initials) )
        {
            ; 声母
            index += 1
            if (InStr("csz", initials)&&(SubStr(str, index, 1)="h")) {
                ; zcs + h
                index += 1
                initials .= "h"
            }
            initials := Format("{:L}", initials)

            ; 韵母
            vowels := ""
            vowels_test_len := 0
            loop {
                if (index+vowels_test_len-A_Index>strlen) {
                    break
                }
                check_char := SubStr(str, index+vowels_test_len, 1)
                if( InStr("AEOBPMFDTNLGKHJQXZCSRYW", check_char, true) ) {
                    str := SubStr(str, 1, index+vowels_test_len-1) . Format("{:L}", check_char) . SubStr(str, index+vowels_test_len+1)
                    break
                }
                vowels_test_len += 1
                if( vowels_test_len >= 4 ) {
                    break
                }
            }

            vowels_len := 0
            loop
            {
                if (index+vowels_test_len-A_Index>strlen) {
                    continue
                }
                vowels_len := vowels_test_len+1-A_Index
                vowels := SubStr(str, index, vowels_len)
                if (pinyin_table[initials][vowels]) {
                    break
                }
                if (A_Index >= vowels_test_len+1) {
                    break
                }
            }

            ; 词库辅助分词
            if( (InStr("n|g", last_char)||(last_char="e"&&initials="r")) && (!vowels||InStr("aeo", initials)) )
            {
                if (pinyin_table[last_initials][SubStr(last_vowels,1,-1)])
                {
                    test_separate_words := LTrim(PinyinSplit(SubStr(str,index-2)), "'")
                    if( InStr(test_separate_words, "'")>2 )
                    {
                        l_weight := CheckPinyinSplit(DB, separate_words . initials vowels . "'")
                        r_weight := CheckPinyinSplit(DB, SubStr(separate_words,1,-2) . "'" . untest_str)
                        if (r_weight >= l_weight)
                        {
                            Assert(SubStr(separate_words,0) == "'")
                            return  SubStr(separate_words,1,-2) "'" test_separate_words
                        }
                    }
                }
            }

            last_vowels     := vowels
            last_initials   := initials
            ; 转全拼显示
            if (show_full) {
                separate_words .= pinyin_table[initials][1] . pinyin_table[initials][vowels] "'"
            }
            else {
                separate_words .= initials . vowels . "'"
            }

            index += vowels_len
            if( pinyin_table[initials][vowels] ){
                last_char := SubStr(pinyin_table[initials][vowels],0)
            } else if( pinyin_table[initials][1] ) {
                last_char := SubStr(pinyin_table[initials][1],0)
            }
        }
        ; 忽略
        else
        {
            index += 1
            last_char := initials
            if( initials!="'" ) {
                separate_words .= initials "'"
            }
        }
    }
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
    rstr:=Trim(rstr,"'"), zero_initials_table:="o"
    if (cpfg:=lianxiang){
        if (rstr~="[\.\*\?\|\[\]]")
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{' AND key REGEXP '^" rstr "' ORDER BY weight DESC LIMIT 3"
        else
            _SQL:="SELECT key,value,weight FROM 'pinyin' WHERE jp>='" tstr "''a' AND jp<'" tstr "''{'" (rstr?" AND key>='" rstr "''a' AND key<'" rstr "''{'":"") " ORDER BY weight DESC LIMIT 3"
    } else if (cjjp&&(scheme~="i)^(abc|wr|sg)sp"||(zero_initials_table:=customspjm[scheme, "0"])~="^[a-zA-Z]$")&&InStr(str, zero_initials_table)){
        tstr:=StrReplace(tstr, zero_initials_table, "_", nCount:=0), rstr:=StrReplace(tstr, "_", "[aoe]")
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