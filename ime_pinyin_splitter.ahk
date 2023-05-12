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

PinyinSplitterGetWeight(pinyin, prev_splitted_input:="")
{
    static splitted_string_weight_table := {}
    if( prev_splitted_input == "" )
    {
        if( !splitted_string_weight_table.HasKey(pinyin) )
        {
            splitted_string_weight_table[pinyin] := PinyinSqlGetWeight(pinyin)
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
    return next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char)
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

    if( !IsCompletePinyin(initials, vowels) ){
        vowels .= "%"
    }
    return vowels
}

PinyinSplitterGetInitials(input_str, initials, ByRef index)
{
    local
    index += 1
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
; In:
;   spell:              a-z
;   tone:               "12345'" and {space}
;   radical:            A-Z
;   maybe has h sound:  ?
; Out:
;   spell:              a-z
;   tone:               012345
;   auto complete:      %
;   maybe has h sound:  ?
;
; Output always has a tone in last char
;
; e.g.
; "wo3ai4ni3" -> [wo3=3,ai4=2,ni3=1] (0)
; "woaini" -> [wo0=3,ai0=2,ni0=1] (0)
; "wo'ai'ni" -> [wo0=3,ai0=2,ni0=1] (0)
; "wo aini" -> [wo0=1,ai0=2,ni0=1] (0)
; "swalb1" -> [s%0=4,wa0=3,l%0=2,b%1=1] (0)
; "zhrmghg" -> [zh%0=6,r%0=5,m%0=4,g%0=3,h%0=2,g%0=1] (0)
; "taNde1B" -> [ta0{N}=2,de1{B}=1] (0)
; "z?eyangz?i3" -> [z?e0=3,yang0=2,z?i3=1] (0)
; "tzh" -> [t%0=3,z%0=2,h%0=1] (0)
; "zhe" -> [zhe0=1] (0)
; "haoN" -> [hao0{N}=1] (0)
;
; See: `PinyinSplitterInputStringTest`
PinyinSplitterInputString(input_string, ByRef auto_complete)
{
    ; last char * marks simple spell
    auto_complete := (SubStr(input_string, -1, 2) == "**") || (SubStr(input_string, 0, 1) == "+")
    simple_spell := (SubStr(input_string, 0, 1) == "*")
    input_string := RTrim(input_string, "*+")

    if( simple_spell )
    {
        splitter_list := PinyinSplitterInputStringSimple(input_string)
    }
    else
    {
        splitter_list := PinyinSplitterInputStringNormal(input_string)
    }

    if( !simple_spell && StrLen(input_string) <= 4 )
    {
        try_simple_spliter := true
        loop, % splitter_list.Length()
        {
            if( SplitterResultIsCompleted(splitter_list[A_Index]) )
            {
                try_simple_spliter := false
                break
            }
        }
        if( try_simple_spliter )
        {
            splitter_list := PinyinSplitterInputStringSimple(input_string)
        }
    }

    return splitter_list
}

PinyinSplitterInputStringSimple(input_string)
{
    local
    Critical
    ImeProfilerBegin(11)

    string_index        := 1
    strlen              := StrLen(input_string)
    splitter_list       := []
    hope_length_list    := [0]
    loop
    {
        if( string_index > strlen ) {
            break
        }

        initials := SubStr(input_string, string_index, 1)
        string_index += 1
        if( IsInitials(initials) )
        {
            start_string_index := string_index
            vowels      := "%"
            tone        := PinyinSplitterGetTone(input_string, initials, vowels, string_index)
            radical := GetRadical(SubStr(input_string, string_index))
            string_index += StrLen(radical)

            make_result := SplitterResultMake(initials . vowels, tone, radical, start_string_index, string_index-1)
            splitter_list.Push(make_result)

            hope_length_list[hope_length_list.Length()] += 1
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

    ImeProfilerEnd(11, "SIM: """ input_string """ -> [" SplitterResultListGetDisplayText(splitter_return_list) "] " "(" splitter_return_list.Length() ")")
    return splitter_return_list
}

PinyinSplitterInputStringNormal(input_string)
{
    local
    Critical
    ImeProfilerBegin(11)

    prev_splitted_input := ""
    string_index        := 1
    start_string_index  := 1
    strlen              := StrLen(input_string)
    splitter_list       := []
    escape_string       := ""
    hope_length_list    := [0]

    loop
    {
        initials := SubStr(input_string, string_index, 1)

        if( string_index > strlen || IsInitials(initials) )
        {
            if( escape_string ) {
                if( RegexMatch(escape_string, "^\s+$") ) {
                    escape_string := ""
                }
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
        if( IsInitials(initials) )
        {
            start_string_index := string_index

            initials    := PinyinSplitterGetInitials(input_string, initials, string_index)
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
            string_index += 1
            if( initials == "'" ){
                initials := " "
            }
            escape_string .= initials
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


    ImeProfilerEnd(11, "NOR: """ input_string """ -> [" SplitterResultListGetDisplayText(splitter_return_list) "] " "(" splitter_return_list.Length() ")")
    return splitter_return_list
}

;*******************************************************************************
; Unit Test
PinyinSplitterInputStringTest()
{
    test_case := ["wo3ai4ni3", "woaini", "wo'ai'ni", "wo aini", "swalb1", "zhrmghg", "taNde1B", "z?eyangz?i3", "tzh", "zhe", "haoN"]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := PinyinSplitterInputString(input_case, auto_complete)
        msg_string .= "`n""" input_case """ -> [" SplitterResultListGetDisplayText(test_result) "] (" auto_complete ")"
    }
    MsgBox, % msg_string
}

PinyinSplitterInputStringUnitTest()
{
    test_case := [ "banan","bingan","canan","changan","change","dingan","dinge","dongan","enai","enen","gangaotai","geren","gongan","heni","henai","jianao","jine","jingai","jinge","keneg","keneng","keren","kune","nanan","pingan","qiane","qinai","qingan","renao","shanao","shane","tigong","tiane","wanan","xianai","xieren","xieri","xinai","daxinganling","yanan","yiner","zhenai","zonge","wanou","lianai","bieren","buhuanersan","changanaotuo","wanganshi","zenmeneng","zenmerang","yixieren","naxieren","xigezao","xilegezao","xieriji" ]
    case_result := [ "ban'an","bing'an","can'an","chang'an","chang'e","ding'an","ding'e","dong'an","en'ai","en'en","gang'ao'tai","ge'ren","gong'an","he'ni","hen'ai","jian'ao","jin'e","jing'ai","jing'e","ke'neng","ke'neng","ke'ren","kun'e","nan'an","ping'an","qian'e","qin'ai","qing'an","re'nao","shan'ao","shan'e","ti'gong","tian'e","wan'an","xian'ai","xie'ren","xie'ri","xin'ai","da'xing'an'ling","yan'an","yin'er","zhen'ai","zong'e","wan'ou","lian'ai","bie'ren","bu'huan'er'san","chang'an'ao'tuo","wang'an'shi","zen'me'neng","zen'me'rang","yi'xie'ren","na'xie'ren","xi'ge'zao","xi'le'ge'zao","xie'ri'ji" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := PinyinSplitterInputString(input_case, auto_complete)
        result_str := ""
        loop, % test_result.Length()
        {
            result_str .= test_result[A_Index, 1] "'"
        }
        result_str := RTrim(result_str, "'")
        if(result_str != case_result[A_Index])
        {
            msg_string .= "`n[" input_case "] -> [" result_str "], [" case_result[A_Index] "]"
        }
    }
    MsgBox, % msg_string
}
