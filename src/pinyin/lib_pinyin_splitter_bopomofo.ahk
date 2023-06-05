; https://pic.pimg.tw/uiop7890/1348566165-395991823.jpg
; https://zh.wikipedia.org/wiki/%E6%B3%A8%E9%9F%B3%E8%BC%B8%E5%85%A5%E6%B3%95#%E9%9B%BB%E8%85%A6%E6%B3%A8%E9%9F%B3%E9%8D%B5%E7%9B%A4
; index == 0 Get initials or tone
; index >= 1 Get vowels
BopomofoToNormal(word, index)
{
    if( word == "" || word == " " ){
        return ""
    }
    index += 1
    static bopomofo_pinyin := {"1":["b"], "q":["p"], "a":["m"], "z":["f"]
    , "2":["d"], "w":["t"], "s":["n"], "x":["l"]
    , "3":["3"], "e":["g"], "d":["k"], "c":["h"]
    , "4":["4"], "r":["j"], "f":["q"], "v":["x"]
    , "5":["zh"], "t":["ch"], "g":["sh"], "b":["r"]
    , "6":["2"], "y":["z"], "h":["c"], "n":["s"]
    , "7":["5"], "u":["y","i"], "j":["w","u"], "m":["y","v"]
    , "8":["a","a"], "i":["o","o"], "k":["e","e"], ",":["e","e"]
    , "9":["ai","ai"], "o":["ei","ei","ui"], "l":["ao","ao"], ".":["ou","ou","iu"]
    , "0":["an","an"], "p":["en","en","in","un"], ";":["ang","ang"], "/":["eng","eng","ing","ong"]
    , "-":["er","r"]}
    Assert(bopomofo_pinyin.HasKey("0"), word)
    normal_words := ""
    loop, Parse, word
    {
        test_word := A_LoopField
        ; `. ""` to force as string
        Assert(bopomofo_pinyin.HasKey(test_word . ""), test_word ", " word)

        normal_word := bopomofo_pinyin[test_word . "", index]
        if( !normal_word ) {
            return ""
        }
        normal_words .= normal_word
    }
    return normal_words
}

PinyinSplitterGetBopomofoInitials(input_str, bopomofo_initials, ByRef index)
{
    local
    index += 1

    initials := BopomofoToNormal(bopomofo_initials, 0)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", bopomofo_initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("zcs", bopomofo_initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}

PinyinSplitterCalcBopomofoMaxVowelsLength(input_str, index)
{
    local
    strlen := StrLen(input_str)
    vowels_max_len := 0
    loop {
        ; Max len is 4
        if( vowels_max_len >= 4 || index+vowels_max_len-A_Index>=strlen ){
            break
        }
        check_bopomofo_char := SubStr(input_str, index+vowels_max_len, 1)
        check_char := BopomofoToNormal(check_bopomofo_char, 0)
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

PinyinSplitterGetBopomofoVowels(input_str, initials, ByRef index, prev_splitted_input)
{
    local
    vowels_max_len  := PinyinSplitterCalcBopomofoMaxVowelsLength(input_str, index)
    bopomofo_vowels := ""
    vowels_len      := 0
    found_vowels    := false
    vowels          := ""
    if( vowels_max_len > 0 )
    {
        loop
        {
            vowels_len := vowels_max_len+1-A_Index
            bopomofo_vowels := SubStr(input_str, index, vowels_len)
            if( IsVowelsAnyMark(bopomofo_vowels) )
            {
                break
            }
            else
            {
                last_vowels := ""
                loop
                {
                    vowels := BopomofoToNormal(bopomofo_vowels, A_Index)
                    if( last_vowels == vowels || vowels == "" ) {
                        break
                    }
                    if( IsCompletePinyin(initials, vowels) )
                    {
                        found_vowels := true
                        break
                    }
                }
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
    else if( !IsCompletePinyin(initials, vowels) ){
        vowels .= "%"
    }
    return vowels
}

;*******************************************************************************
;
PinyinSplitterInputStringBopomofo(input_string)
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
        bopomofo_initials := SubStr(input_string, string_index, 1)
        initials := BopomofoToNormal(bopomofo_initials, 0)

        if( string_index > strlen || IsInitials(initials) || IsInitialsAnyMark(initials) )
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
        if( IsInitials(SubStr(initials,1,1)) || IsInitialsAnyMark(initials) )
        {
            start_string_index := string_index

            initials    := PinyinSplitterGetBopomofoInitials(input_string, bopomofo_initials, string_index)
            vowels      := PinyinSplitterGetBopomofoVowels(input_string, initials, string_index, prev_splitted_input)
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
            if( initials == "'" ){
                initials := " "
            }
            string_index += 1
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
