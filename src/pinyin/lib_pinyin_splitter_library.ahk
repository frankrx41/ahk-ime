;*******************************************************************************
; Static
PinyinSplitterGetTone(input_str, initials, vowels, ByRef index)
{
    local
    strlen := StrLen(input_str)
    tone := SubStr(input_str, index, 1)
    if( IsTone(tone) ) {
        index += 1
        if( tone == " " || tone == "'" ){
            tone := 0
        }
    } else {
        tone := 0
    }
    return tone
}

PinyinSplitterMaxVowelsLength(input_str, index)
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
        if( IsVowelsAnyMark(check_char) )
        {
            if( vowels_max_len == 0 ){
                vowels_max_len := 1
            }
            break
        }
        if( IsTone(check_char) ){
            break
        }
        if( IsRadical(check_char) ){
            break
        }
        if( IsRadical(check_char) ){
            break
        }
        if( IsInitialsAnyMark(check_char) ){
            break
        }
        vowels_max_len += 1
    }
    return vowels_max_len
}

PinyinSplitterGetWeight(pinyin, prev_splitted_input:="", update:=false)
{
    static splitted_string_weight_table := {}
    Assert(pinyin)
    if( prev_splitted_input == "" )
    {
        if( !splitted_string_weight_table.HasKey(pinyin) )
        {
            splitted_string_weight_table[pinyin] := PinyinSqlGetWeight(pinyin, false)
        }
        if( update ) {
            splitted_string_weight_table[pinyin] += 1
        }
        return splitted_string_weight_table[pinyin]
    }
    else
    {
        return Max(PinyinSplitterGetWeight(prev_splitted_input . pinyin), PinyinSplitterGetWeight(pinyin))
    }
}

;*******************************************************************************
; ban'an -> [ba'nan]
; xie'ru -> [xi'eru]
; tig'ong -> [ti'gong + tig'ong] + [ti'gon + tig'on] + [ti'go + tig'o]
; le'ge -> [leg'e]
PinyinSplitterCheckDBWeight(left_initials, left_vowels, right_string, prev_splitted_input)
{
    right_string_len := StrLen(right_string)
    left_vowels_cut_last := SubStr(left_vowels, 1, StrLen(left_vowels)-1)
    left_vowels_last := SubStr(left_vowels, 0, 1)
    right_initials := SubStr(right_string, 1, 1)

    profile_text := ImeProfilerBegin(13)

    max_test_len := Min(8, right_string_len)

    max_word_weight := 0
    result_word := ""
    loop,
    {
        test_len := max_test_len - A_Index + 1
        if( test_len <= 0 ) {
            break
        }
        next_char := SubStr(right_string, test_len+1, 1)
        if( IsMustSplit(next_char) || IsInitials(next_char) )
        {
            test_right_string := SubStr(right_string, 1, test_len)
            if( IsCompletePinyin(left_vowels_last, test_right_string) )
            {
                full_vowels := GetFullVowels(left_vowels_last, test_right_string)
                test_word := left_initials . left_vowels_cut_last "0" left_vowels_last . full_vowels "0"
                word_weight := PinyinSplitterGetWeight(test_word, prev_splitted_input)
                if( word_weight > max_word_weight ){
                    max_word_weight := word_weight
                    result_word := left_initials . left_vowels_cut_last
                }
            }

            test_right_string_cut := SubStr(right_string, 2, test_len-1)
            if( IsCompletePinyin(right_initials, test_right_string_cut) )
            {
                full_vowels := GetFullVowels(right_initials, test_right_string_cut)
                test_word := left_initials . left_vowels "0" right_initials . full_vowels "0"
                word_weight := PinyinSplitterGetWeight(test_word, prev_splitted_input)
                if( word_weight > max_word_weight ){
                    max_word_weight := word_weight
                    result_word := left_initials . left_vowels
                }
            }
        }
    }
    ImeProfilerEnd(13, profile_text)

    if( max_word_weight > 0 )
    {
        return (left_initials . left_vowels) == result_word
    }

    first_char := SubStr(right_string, 1, 1)
    if( IsZeroInitials(first_char) ){
        if( !IsCompletePinyin(first_char, SubStr(right_string, 2, 1)) && !IsCompletePinyin(first_char, SubStr(right_string, 2, 2)) ){
            return false
        }
    }

    return true
}

PinyinSplitterIsGraceful(left_initials, left_vowels, right_string, prev_splitted_input)
{
    next_char := SubStr(right_string, 1, 1)
    if( !right_string || IsTone(next_char) ){
        return true
    }

    right_initials := SubStr(left_vowels, 0, 1)
    if( right_initials == "?" ){
        return true
    }

    left_vowels_cut := SubStr(left_vowels, 1, StrLen(left_vowels)-1)
    if( IsCompletePinyin(left_initials, left_vowels_cut) )
    {
        return PinyinSplitterCheckDBWeight(left_initials, left_vowels, right_string, prev_splitted_input)
    }
    else
    {
        return true
    }
}

IsMustSplit(next_char)
{
    return next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char) || IsInitialsAnyMark(next_char)
}

PinyinSplitterGetVowels(input_str, initials, ByRef index, prev_splitted_input)
{
    local
    ; 最长是4个
    vowels_max_len := PinyinSplitterMaxVowelsLength(input_str, index)
    vowels      := ""
    vowels_len  := 0
    if( vowels_max_len > 0 )
    {
        loop
        {
            vowels_len := vowels_max_len+1-A_Index
            vowels := SubStr(input_str, index, vowels_len)
            if( IsVowelsAnyMark(vowels) )
            {
                break
            }
            if( IsCompletePinyin(initials, vowels) )
            {
                next_char := SubStr(input_str, index+vowels_len, 1)
                if( IsMustSplit(next_char) ){
                    break
                }
                if( !IsZeroInitials(initials) && vowels_len == 1 ){
                    break
                }
                if( IsInitials(next_char) && PinyinSplitterIsGraceful(initials, vowels, SubStr(input_str, index+vowels_len), prev_splitted_input) ) {
                    break
                }
            }
            if( A_Index >= vowels_max_len+1 ){
                break
            }
        }
    }
    index += vowels_len

    if( IsVowelsAnyMark(vowels) ){
        vowels := "%"
    }
    else if( !IsCompletePinyin(initials, vowels) ){
        vowels .= "%"
    }
    return vowels
}

PinyinSplitterGetInitials(input_str, initials, ByRef index)
{
    local
    index += 1
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("zcs", initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}
