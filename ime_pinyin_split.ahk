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
