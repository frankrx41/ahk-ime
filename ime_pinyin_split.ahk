IsTone(tone)
{
    return tone && InStr("12345' ", tone)
}

GetTone(input_str, initials, vowels, ByRef index)
{
    local
    strlen := StrLen(input_str)
    tone := SubStr(input_str, index, 1)
    if( IsTone(tone) ) {
        index += 1
        ; TODO: make space work to split words
        tone := tone == " " ? "'" : tone
    } else {
        if( index < strlen+1 ){
            tone := "-"
        } else {
            tone := IsFullPinyin(initials, vowels) ? "'" : ""
        }
    }
    return tone
}

CalcMaxVowelsLength(input_str, index)
{
    local
    strlen := StrLen(input_str)
    vowels_max_len := 0
    loop {
        ; Max len is 4
        if( vowels_max_len >= 4 || index+vowels_max_len-A_Index>=strlen ){
            break
        }
        check_char := SubStr(input_str, index+vowels_max_len, 1)
        if( IsTone(check_char) ){
            break
        }
        if( InStr("AEOBPMFDTNLGKHJQXZCSRYW", check_char, true) ) {
            break
        }
        vowels_max_len += 1
    }
    return vowels_max_len
}

GetVowels(input_str, initials, ByRef index)
{
    local
    ; 最长是4个
    vowels_max_len := CalcMaxVowelsLength(input_str, index)
    vowels      := ""
    vowels_len  := 0
    if( vowels_max_len > 0 )
    {
        loop
        {
            vowels_len := vowels_max_len+1-A_Index
            vowels := SubStr(input_str, index, vowels_len)
            if( IsFullPinyin(initials, vowels) ){
                next_char := SubStr(input_str, vowels_len+2, 1)
                if( next_char == "" || IsInitials(next_char) ){
                    break
                }
            }
            if( A_Index >= vowels_max_len+1 ){
                break
            }
        }
    }
    index += vowels_len

    if( !IsFullPinyin(initials, vowels) ){
        vowels .= "%"
    }
    return vowels
}

GetInitials(input_str, initials, ByRef index)
{
    local
    index += 1
    if( InStr("csz", initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    initials := Format("{:L}", initials)
    return initials
}

; 拼音音节切分
; ' 表示自动分词
; 12345 空格 大写 表示手动分词
PinyinSplit(origin_input, show_full:=0, DB:="")
{
    local
    Critical
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
        ; 字母，自动分词
        if( IsInitials(initials) )
        {
            start_index := index

            ; 声母
            initials := GetInitials(input_str, initials, index)

            ; 韵母
            vowels := GetVowels(input_str, initials, index)
            full_vowels := GetFullVowels(initials, vowels)

            ; 声调
            tone := GetTone(input_str, initials, vowels, index)

            ; 词库辅助分词
            if( (InStr("n|g", last_char)||(last_char="e"&&initials="r")) && (!vowels||InStr("aeo", initials)) )
            {
                cutted_last_vowels := SubStr(last_vowels,1,-1)
                if( IsFullPinyin(last_initials, cutted_last_vowels) )
                {
                    prev_separate_words := PinyinSplit(SubStr(input_str, start_index-1))
                    str_left := separate_words . initials . vowels . tone
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

            last_initials   := initials
            last_vowels     := vowels

            if( !IsTone(tone) ){
                if( full_vowels ){
                    last_char := SubStr(full_vowels,0)
                } else if( initials ) {
                    last_char := SubStr(initials,0)
                }
            } else {
                last_char := "'"
            }

            ; 更新音调
            tone := tone != "" ? IsTone(tone) ? tone : "'" : ""
            ; 转全拼显示
            if( show_full ){
                Assert(initials == GetFullInitials(initials))
                
                vowels := full_vowels ? full_vowels : vowels
            }
            separate_words .= initials . vowels . tone
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
