
IsMustSplit(next_char)
{
    return next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char) || IsInitialsAnyMark(next_char)
}

;*******************************************************************************
;
PinyinSplitterGetWeight(pinyin, prev_splitted_input:="")
{
    static splitted_string_weight_table := {}
    Assert(pinyin, "", false)
    if( prev_splitted_input == "" )
    {
        if( !splitted_string_weight_table.HasKey(pinyin) )
        {
            splitted_string_weight_table[pinyin] := PinyinSqlGetWeight(pinyin, false)
        }
        return splitted_string_weight_table[pinyin]
    }
    else
    {
        return Max(PinyinSplitterGetWeight(prev_splitted_input . pinyin), PinyinSplitterGetWeight(pinyin))
    }
}

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

    ImeProfilerBegin()

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
    ImeProfilerEnd()

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

;*******************************************************************************
;
NormalToNormal(word, index)
{
    return word
}

;*******************************************************************************
;
PinyinSplitterGetInitials(input_str, initials, ByRef index, covert_func:="NormalToNormal")
{
    local
    index += 1
    
    initials := Func(covert_func).Call(initials, 0)
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

;*******************************************************************************
; `allow_max_len`: max length may be 4, e.g. "iong" "uang"
PinyinSplitterCalcMaxVowelsLength(input_str, index, covert_func, allow_max_len)
{
    local
    strlen := StrLen(input_str)
    vowels_max_len := 0
    loop {
        if( vowels_max_len >= allow_max_len || index+vowels_max_len-1>=strlen ){
            break
        }
        check_char := SubStr(input_str, index+vowels_max_len, 1)
        check_char := Func(covert_func).Call(check_char, 0)

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

PinyinSplitterGetVowels(input_str, initials, ByRef index, prev_splitted_input, covert_func:="NormalToNormal", allow_max_len:=4)
{
    local
    vowels_max_len  := PinyinSplitterCalcMaxVowelsLength(input_str, index, covert_func, allow_max_len)
    vowels          := ""
    vowels_len      := 0
    found_vowels    := false
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
            last_vowels := ""
            loop
            {
                covert_vowels := Func(covert_func).Call(vowels, A_Index)
                if( last_vowels == covert_vowels ) {
                    break
                }
                if( IsCompletePinyin(initials, covert_vowels) ) {
                    if( PinyinSplitterCheckCanSplit(input_str, index, initials, vowels, vowels_len, prev_splitted_input) ){
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
    index += vowels_len

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

;*******************************************************************************
;
PinyinSplitterInputStringNormal(input_string)
{
    local
    Critical
    ImeProfilerBegin()

    prev_splitted_input := ""
    string_index        := 1
    start_string_index  := 1
    strlen              := StrLen(input_string)
    splitter_list       := []
    escape_string       := ""
    hope_length_list    := [0]

    loop
    {
        check_mark := SubStr(input_string, string_index, 1)

        if( string_index > strlen || IsInitials(check_mark) || IsInitialsAnyMark(check_mark) || IsRepeatMark(check_mark) )
        {
            if( escape_string ) {
                make_result := SplitterResultMake(escape_string, 0, "", start_string_index, string_index-1, false)
                splitter_list.Push(make_result)
                escape_string := ""
            }
        }

        if( string_index > strlen )
        {
            break
        }

        ; 字母，自动分词
        if( IsInitials(check_mark) || IsInitialsAnyMark(check_mark) || IsRepeatMark(check_mark) )
        {
            start_string_index := string_index

            if( !IsRepeatMark(check_mark) )
            {
                initials    := PinyinSplitterGetInitials(input_string, check_mark, string_index)
                vowels      := PinyinSplitterGetVowels(input_string, initials, string_index, prev_splitted_input)
                full_vowels := GetFullVowels(initials, vowels)
                tone_string := SubStr(input_string, string_index, 1)
                tone        := PinyinSplitterGetTone(input_string, initials, vowels, string_index)

                if( !InStr(vowels, "%") && !IsCompletePinyin(initials, vowels, tone) ){
                    vowels .= "%"
                }
                else
                {
                    ; 转全拼显示
                    vowels := full_vowels ? full_vowels : vowels
                }

                ; Radical
                radical := GetRadical(SubStr(input_string, string_index))
                string_index += StrLen(radical)
            } else {
                string_index += 1
            }

            make_result := SplitterResultMake(initials . vowels, tone, radical, start_string_index, string_index-1)
            splitter_list.Push(make_result)

            prev_splitted_input := initials . vowels . tone

            hope_length_list[hope_length_list.Length()] += 1
            if( tone_string == " " ){
                hope_length_list.Push(0)
            }
        }
        ; 忽略
        else
        {
            if( check_mark == "'" ){
                check_mark := " "
            }
            string_index += 1
            escape_string .= check_mark
        }
    }

    splitter_return_list := []
    loop, % splitter_list.Length()
    {
        splitter_result := splitter_list[A_Index]
        pinyin          := SplitterResultGetPinyin(splitter_result)
        tone            := SplitterResultGetTone(splitter_result)
        radical         := SplitterResultGetRadical(splitter_result)
        start_pos       := SplitterResultGetStartPos(splitter_result)
        end_pos         := SplitterResultGetEndPos(splitter_result)
        need_translate  := SplitterResultNeedTranslate(splitter_result)

        if( need_translate ){
            if( hope_length_list[1] == 0 ){
                hope_length_list.RemoveAt(1)
            }
            hope_length := hope_length_list[1]
            hope_length_list[1] -= 1
        } else {
            hope_length := 1
        }

        make_result := SplitterResultMake(pinyin, tone, radical, start_pos, end_pos, need_translate, hope_length)
        splitter_return_list.Push(make_result)
    }


    ImeProfilerEnd("NOR: """ input_string """ -> [" SplitterResultListGetDebugText(splitter_return_list) "] " "(" splitter_return_list.Length() ")")
    return splitter_return_list
}
