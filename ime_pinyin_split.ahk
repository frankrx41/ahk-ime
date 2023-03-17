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
            tone := IsCompletePinyin(initials, vowels) ? "'" : ""
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
            if( IsCompletePinyin(initials, vowels) )
            {
                next_char := SubStr(input_str, index+vowels_len, 1)
                ; tooltip_debug[1] .= "(" next_char ")"
                if( CheckSplitAble(initials, vowels, next_char) && CheckSplitWeight(initials, vowels, next_char) )
                {
                    break
                }
            }
            if( A_Index >= vowels_max_len+1 ){
                break
            }
        }
    }
    index += vowels_len

    if( !IsCompletePinyin(initials, vowels) ){
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

            initials    := GetInitials(input_str, initials, index)
            vowels      := GetVowels(input_str, initials, index)
            full_vowels := GetFullVowels(initials, vowels)
            tone        := GetTone(input_str, initials, vowels, index)

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
            if( initials!="'" ) {
                separate_words .= initials "'"
            }
        }
    }

    tooltip_debug[1] .= origin_input "->[" separate_words "] "
    return separate_words
}

CheckSplitAble(left_initials, left_vowels, next_char)
{
    return next_char == "" || IsInitials(next_char) || IsTone(next_char)
}

CheckSplitWeight(left_initials, left_vowels, next_char)
{
    if( !next_char ){
        return true
    }

    last_char := SubStr(left_vowels, 0, 1)
    if( IsCompletePinyin(last_char, next_char) )
    {
        return false
    }

    return true
}