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

IsSplitAbleAt(next_char)
{
    return next_char == "" || IsInitials(next_char) || IsTone(next_char)
}

IsInSplitTable(left_initials, left_vowels, right_string)
{
    static split_weight_table := {"re'nao":1, "en'en":1}
    right_string_len := StrLen(right_string)
    loop, 5
    {
        key := left_initials . left_vowels . "'" . SubStr(right_string, 1, A_Index)
        if( split_weight_table.HasKey(Key) ){
            return true
        }
        if( A_Index >= right_string_len ){
            break
        }
    }
    return false
}

IsGracefulSplit(left_initials, left_vowels, right_string)
{
    next_char := SubStr(right_string, 1, 1)
    if( !right_string || IsTone(next_char) ){
        return true
    }
    ; angan -> a + ng + an
    ; enen -> e + n + en
    right_initials := SubStr(left_vowels, 0, 1)
    if( IsCompletePinyin(right_initials, next_char) )
    {
        return IsInSplitTable(left_initials, left_vowels, right_string)
    }

    return true
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
                if( IsSplitAbleAt(next_char) && IsGracefulSplit(initials, vowels, SubStr(input_str, index+vowels_len)) )
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
