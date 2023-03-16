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

    PinyinAssistantInitialize()
}

IsSplitMark(character)
{
    return character ~= "\d" || character == " " || character == "'"
}

; 拼音音节切分
; ' 表示自动分词
; 12345 空格 大写 表示手动分词
PinyinSplit(origin_input, pinyintype:="pinyin", show_full:=0, DB:="")
{
    local
    Critical
    global pinyin_table
    global tooltip_debug

    index           := 1
    separate_words  := ""
    input_str       := origin_input
    strlen          := StrLen(input_str)
    last_char       := ""
    last_vowels     := ""
    last_initials   := ""

    loop
    {
        if( index > strlen ) {
            break
        }

        initials := SubStr(input_str, index, 1)
        ; 数字 空格 强制分词
        if( IsSplitMark(initials) )
        {
            if( initials != " " ) {
                separate_words := RTrim(separate_words,"'") . initials
            } else {
                separate_words .= "|'"
            }
            index += 1
            last_char := "'"
            continue
        }
        ; 字母，自动分词
        else if( pinyin_table.HasKey(initials) )
        {
            ; 声母
            index += 1
            if( InStr("csz", initials) && (SubStr(input_str, index, 1)=="h") ){
                ; zcs + h
                index += 1
                initials .= "h"
            }
            initials := Format("{:L}", initials)

            ; 韵母
            vowels := ""
            vowels_test_len := 0
            loop {
                if( vowels_test_len >= 4 || index+vowels_test_len-A_Index>=strlen ){
                    break
                }
                check_char := SubStr(input_str, index+vowels_test_len, 1)
                if( IsSplitMark(check_char) ){
                    break
                }
                if( InStr("AEOBPMFDTNLGKHJQXZCSRYW", check_char, true) ) {
                    input_str := SubStr(input_str, 1, index+vowels_test_len-1) . Format("{:L}", check_char) . SubStr(input_str, index+vowels_test_len+1)
                    break
                }
                vowels_test_len += 1
            }

            vowels_len := 0
            if( vowels_test_len > 0 ) {
                loop
                {
                    if( index+vowels_test_len-A_Index > strlen ){
                        continue
                    }
                    vowels_len := vowels_test_len+1-A_Index
                    vowels := SubStr(input_str, index, vowels_len)
                    if( pinyin_table[initials][vowels] ){
                        break
                    }
                    if( A_Index >= vowels_test_len+1 ){
                        break
                    }
                }
            }

            ; 词库辅助分词
            if( (InStr("n|g", last_char)||(last_char="e"&&initials="r")) && (!vowels||InStr("aeo", initials)) )
            {
                if( pinyin_table[last_initials][SubStr(last_vowels,1,-1)] )
                {
                    prev_separate_words := PinyinSplit(SubStr(input_str,index-2))
                    if( InStr(prev_separate_words, "'")>2 )
                    {
                        str_left := separate_words . initials vowels . "'"
                        str_right := SubStr(separate_words,1,-2) . "'" . prev_separate_words
                        weight_left := PinyinCheckWeight(DB, str_left)
                        weight_right := PinyinCheckWeight(DB, str_right)
                        if( weight_right >= weight_left )
                        {
                            Assert(SubStr(separate_words,0) == "'")
                            separate_words := SubStr(separate_words,1,-2) "'" prev_separate_words
                            tooltip_debug[1] .= origin_input "->[" separate_words "] "
                            return separate_words
                        }
                    }
                }
            }

            last_initials   := initials
            last_vowels     := vowels
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
    tooltip_debug[1] .= origin_input "->[" separate_words "] "
    return separate_words
}

PinyinCheckWeight(DB, origin_input)
{
    local
    static weight_data := []
    static check_split_cnt := 0
    global tooltip_debug

    if( !DB ){
        Assert(0, "DB error")
        return -1
    }

    input_str := origin_input
    input_str := StrReplace(input_str, "'", "''")
    input_str := StrReplace(input_str, "'|'")
    if( weight_data[input_str] != "" ){
        tooltip_debug[7] .= ": [" input_str "]->(" weight_data[input_str] ") `n"
        return weight_data[input_str]
    }

    sim_str := RegExReplace(Trim(input_str, "'"), "([a-z])[a-z]+", "$1")
    key_str := RegExReplace(input_str, "'([csz]h?)'", "'$1.*'")
    sql_cmd := "SELECT weight FROM pinyin WHERE jp='" sim_str "' AND key REGEXP '^" Trim(key_str,"'") "$' ORDER BY weight DESC LIMIT 1"
    if( DB.GetTable(sql_cmd,Result) )
    {
        check_split_cnt += 1
        weight_data[input_str] := Result.Rows[1][1] ? Result.Rows[1][1] : 0
        tooltip_debug[7] .= check_split_cnt . ": [" input_str "]->(" weight_data[input_str] ") `n"
        return weight_data[input_str]
    }
    else
    {
        Assert(0, "SQL error: " . sql_cmd)
        return -1
    }
}

Get_jianpin(DB, scheme, str, RegExObj:="", lianxiang:=1, LimitNum:=100, cjjp:=false)
{
    local
    Critical
    global tooltip_debug
    customspjm := []
    orgin_str := str
    ystr := Trim(str, "'")
    rstr := ""

    ; if( scheme ){
    ;     str:=PinyinSplit(str,scheme,1)
    ; }
    str := Trim(str, "'")
    str := StrReplace(str, "'", "_")
    str := StrReplace(str, "on'", "ong'")
    tstr := Trim(RegExReplace(str, "([a-z]h?)[a-gi-z]+", "$1", nCount), "'")
    tstr := RegExReplace(tstr, "([csz])h", "$1")

    if( nCount ){
        rstr := RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
        loop % RegExObj.Length() {
            rstr := RegExReplace(rstr, RegExObj[A_Index,1], RegExObj[A_Index,2])
        }
    } 
    else
    {
        tRegEx := ""
        for _,key in ["c","s","z"] {
            if InStr(str,key "h")&&!InStr(RegExObj[1,1],key) {
                tRegEx .= key
            }
        }
        if( tRegEx ){
            rstr := RegExReplace(str, "'([^aoe]h?)'", "'$1[a-z]*'")
            if( StrLen(tstr)==1 )
                LimitNum:=100
        }
    }

    if (rstr=="") {
        if (str~="^''[aoe](''[aoe])*''$") {
            rstr:=str
        } else {
            LimitNum:=100
        }
    }

    if( !InStr("_12345", SubStr(rstr, 0, 1)) ){
        rstr .= "%"
    }
    if( !InStr("_12345", SubStr(tstr, 0, 1)) ){
        tstr .= "_"
    }

    rstr := Trim(rstr,"'")
    zero_initials_table:="o"
    if( lianxiang ){
        if( rstr~="[\.\*\?\|\[\]]" )
            _SQL:="jp>='" tstr "''a' AND jp<'" tstr "''{' AND key REGEXP '^" rstr "' ORDER BY weight DESC LIMIT 3"
        else
            _SQL:="jp>='" tstr "''a' AND jp<'" tstr "''{'" (rstr?" AND key>='" rstr "''a' AND key<'" rstr "''{'":"") " ORDER BY weight DESC LIMIT 3"
    } else if (cjjp&&(scheme~="i)^(abc|wr|sg)sp"||(zero_initials_table:=customspjm[scheme, "0"])~="^[a-zA-Z]$")&&InStr(str, zero_initials_table)){
        tstr:=StrReplace(tstr, zero_initials_table, "_", nCount:=0), rstr:=StrReplace(tstr, "_", "[aoe]")
        if( nCount>4 )
            _SQL:="" Format("((jp>='{:s}a' AND jp<'{:s}b') OR (jp>='{:s}e' AND jp<'{:s}f') OR (jp>='{:s}o' AND jp<'{:s}p')) AND", SubStr(tstr, 1, InStr(tstr, "_")-1)) " jp like '" tstr "' AND jp REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
        else
            _SQL:="jp IN " enumlsm(tstr) " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
    } else {
        if( rstr~="[\.\*\?\|\[\]]" )
            _SQL:="jp='" tstr "' AND key REGEXP '^" rstr "$' ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
        else
            _SQL:="jp LIKE '" tstr "'" (rstr?" AND key LIKE '" rstr "'":"") " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
            ; _SQL:="jp='" tstr "'" (rstr?" AND key='" rstr "'":"") " ORDER BY weight DESC" (LimitNum?" LIMIT " LimitNum:"")
    }

    tooltip_debug[3] .= "`n[" ystr "]: """ _SQL
    if( DB.GetTable("SELECT key,value,weight FROM 'pinyin' WHERE " _SQL, result_table) )
    {
        ; result_table.Rows = [
        ;   ["wu'hui", "舞会", "30000"]
        ;   ["wu'hui", "误会", "26735"]
        ; ]

        if( result_table.RowCount && !lianxiang )
        {
            loop % result_table.RowCount {
                result_table.Rows[A_Index, -1] := ystr
                result_table.Rows[A_Index, 0] := "pinyin|" A_Index
                result_table.Rows[A_Index, 4] := result_table.Rows[1, 3]
            }
        }
        result_table.Rows[0] := ystr
        ; result_table.Rows = [
        ;   [0]: "wu'hui"
        ;        ; -1     , 0         , 1
        ;   [1]: ["wu'hui", "pinyin|1", "wu'hui", "舞会", "30000", "30000"]
        ;   [2]: ["wu'hui", "pinyin|2", "wu'hui", "误会", "26735", "30000"]
        ; ]

        tooltip_debug[3] .= """->(" result_table.RowCount ")"
        ; tooltip_debug[3] .= "`n" ystr "," rstr ": " result_table.RowCount " (" orgin_str ")" "`n" _SQL "`n" CallStack(1)
        return result_table.Rows
    } else {
        return []
    }
}

enumlsm( str )
{
    local res, t
    res:=[""]
    t:=""
    loop, Parse, str
    {
        if (A_LoopField="_")
        {
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
    str := ""
    loop % res.Length() {
        res[A_Index] := res[A_Index] t
        str .= ",'" res[A_Index] "'"
    }
    return "(" LTrim(str, ",") ")"
}
