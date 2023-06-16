IsMustSplit(next_char)
{
    return next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char) || IsInitialsAnyMark(next_char)
}

PinyinSplitterCheckCanSplit(input_str, index, initials, vowels, vowels_len, prev_splitted_input)
{
    next_char := SubStr(input_str, index+vowels_len, 1)
    if( IsMustSplit(next_char) ){
        return true
    }
    if( !IsZeroInitials(initials) && vowels_len == 1 ){
        return true
    }
    if( IsInitials(next_char) && PinyinSplitterIsGraceful(initials, vowels, SubStr(input_str, index+vowels_len), prev_splitted_input) ) {
        return true
    }
    return false
}

;*******************************************************************************
; `allow_max_len`: max length may be 4, e.g. "iong" "uang"
PinyinSplitterCalcMaxVowelsLength(input_str, allow_max_len:=4)
{
    local
    strlen := StrLen(input_str)
    vowels_max_len := 0
    loop {
        if( vowels_max_len >= allow_max_len || vowels_max_len>=strlen ){
            break
        }
        check_char := SubStr(input_str, vowels_max_len+1, 1)

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

PinyinSplitterParseVowels(input_str, initials, prev_splitted_input, ByRef parsing_length, covert_func:="NormalToNormal")
{
    local
    vowels_max_len  := PinyinSplitterCalcMaxVowelsLength(input_str, 4)
    vowels          := ""
    vowels_len      := 0
    parsing_length  := 0
    found_vowels    := false
    if( vowels_max_len > 0 )
    {
        loop
        {
            vowels_len := vowels_max_len+1-A_Index
            vowels := SubStr(input_str, 1, vowels_len)
            if( IsVowelsAnyMark(vowels) )
            {
                break
            }
            last_vowels := ""
            loop
            {
                covert_vowels := Func(covert_func).Call(vowels, A_Index)
                if( last_vowels == covert_vowels ) {
                    break
                }
                if( IsCompletePinyin(initials, covert_vowels) ) {
                    if( PinyinSplitterCheckCanSplit(input_str, 1, initials, vowels, vowels_len, prev_splitted_input) ){
                        vowels := covert_vowels
                        found_vowels := true
                        break
                    }
                }
                last_vowels := covert_vowels
            }
            if( A_Index >= vowels_max_len+1 || found_vowels ){
                break
            }
        }
    }
    parsing_length := vowels_len

    if( IsVowelsAnyMark(vowels) ){
        vowels := "%"
    }
    else if( initials ) {
        if( !IsCompletePinyin(initials, vowels) ){
            vowels .= "%"
        }
    } else {
        if( !IsCompletePinyin(vowels, "") ){
            vowels .= "%"
        }
    }

    return vowels
}
