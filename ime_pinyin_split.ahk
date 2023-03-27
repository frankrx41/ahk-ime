SplitWordGetWordCount(word)
{
    ; 包含 word + tone + word + ... 格式
    RegExReplace(word, "(['12345])", "", count)
    return count
}

SplitWordTrimMaxCount(word, max)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

SplitWordRemoveFirstWord(word)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^[^'12345]+['12345]?")
}

SplitWordRemoveLastWord(word)
{
    ; "kai'xin'a'" -> "kai'xin'"
    return RegExReplace(word, "(['12345])([^'12345]+['12345]?)$", "$1")
}

;*******************************************************************************
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
        if( tone == " " ){
            tone := "'"
        }
    } else {
        tone := "'"
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

PinyinSplitTableInitialize()
{
    global split_weight_table := {}
    FileRead, file_content, data\pinyin-split.txt
    Loop, Parse, file_content, `n
    {
        key := RTrim(A_LoopField, "`r")
        if( key ){
            split_weight_table[key] := 1
        }
    }
    Assert(split_weight_table.Count() != 0)
}

IsInSplitTable(left_initials, left_vowels, right_string)
{
    global split_weight_table
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

    right_initials := SubStr(left_vowels, 0, 1)
    is_complete := 0
    if( next_char == "o" ){
        is_complete += IsCompletePinyin(right_initials, "on")
    }

    if( is_complete || IsCompletePinyin(right_initials, next_char) )
    {
        return IsInSplitTable(left_initials, left_vowels, right_string)
    }
    else
    {
        return true
    }
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
PinyinSplit(origin_input, ByRef split_index_arr)
{
    local
    Critical
    global tooltip_debug

    index           := 1
    separate_words  := ""
    input_str       := origin_input
    strlen          := StrLen(input_str)
    split_index_arr := []

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

            ; 转全拼显示
            Assert(initials == GetFullInitials(initials))
            vowels := full_vowels ? full_vowels : vowels

            separate_words .= initials . vowels . tone

            split_index_arr.Push(index-1)
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
