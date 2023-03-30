;*******************************************************************************
IsTone(tone)
{
    return tone && InStr("12345' ", tone)
}

IsRadical(char)
{
    return InStr("AEOBPMFDTNLGKHJQXZCSRYW", char, true)
}

IsSymbol(char)
{
    global symbol_list_string
    return InStr(symbol_list_string, char)
}

;*******************************************************************************
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

PinyinSplitGetTone(input_str, initials, vowels, ByRef index)
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

PinyinSplitMaxVowelsLength(input_str, index)
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
        if( IsRadical(check_char) ) {
            break
        }
        vowels_max_len += 1
    }
    return vowels_max_len
}

PinyinSplitIsInTable(left_initials, left_vowels, right_string)
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

PinyinSplitIsGraceful(left_initials, left_vowels, right_string)
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
        return PinyinSplitIsInTable(left_initials, left_vowels, right_string)
    }
    else
    {
        return true
    }
}

PinyinSplitGetVowels(input_str, initials, ByRef index)
{
    local
    ; 最长是4个
    vowels_max_len := PinyinSplitMaxVowelsLength(input_str, index)
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
                if( next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char) ) {
                    break
                }
                if( !IsZeroInitials(initials) && vowels_len == 1 ){
                    break
                }
                if( IsInitials(next_char) && PinyinSplitIsGraceful(initials, vowels, SubStr(input_str, index+vowels_len)) ) {
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

PinyinSplitGetInitials(input_str, initials, ByRef index)
{
    local
    index += 1
    if( InStr("csz", initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("csz", initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}

; 拼音音节切分
; ' 表示自动分词
; 12345 空格 大写 表示手动分词
PinyinSplit(origin_input, ByRef split_indexs, ByRef radical_list)
{
    local
    Critical
    ImeProfilerBegin(11)

    index           := 1
    separate_words  := ""
    input_str       := origin_input
    strlen          := StrLen(input_str)
    split_indexs    := []
    radical_list    := []
    has_skip_char   := false

    loop
    {
        if( index > strlen ) {
            break
        }

        initials := SubStr(input_str, index, 1)
        ; 字母，自动分词
        if( IsInitials(initials) )
        {
            if( has_skip_char ) {
                has_skip_char := false
                separate_words .= EscapeCharsGetMark(1)
                split_indexs.Push(index-1)
                radical_list.Push("")
            }

            start_index := index

            initials    := PinyinSplitGetInitials(input_str, initials, index)
            vowels      := PinyinSplitGetVowels(input_str, initials, index)
            full_vowels := GetFullVowels(initials, vowels)
            tone        := PinyinSplitGetTone(input_str, initials, vowels, index)

            if( !InStr(vowels, "%") && !IsCompletePinyin(initials, vowels, tone) ){
                vowels .= "%"
            }
            ; 转全拼显示
            else
            {
                vowels := full_vowels ? full_vowels : vowels
            }

            separate_words .= initials . vowels . tone

            ; Radical
            RegExMatch(SubStr(input_str, index), "^([A-Z]+)", radical)
            index += StrLen(radical)
            radical_list.Push(radical)

            ; Store index
            split_indexs.Push(index-1)
        }
        ; 忽略
        else
        {
            index += 1
            if( initials!="'" ) {
                if( !has_skip_char ) {
                    has_skip_char := true
                    separate_words .= EscapeCharsGetMark(0)
                }
                separate_words .= initials
            }
        }
    }

    if( has_skip_char ) {
        separate_words .= EscapeCharsGetMark(1)
        split_indexs.Push(index-1)
    }

    ImeProfilerEnd(11, """" origin_input """->[" separate_words "] ")
    return separate_words
}
