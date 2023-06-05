; https://zh.wikipedia.org/wiki/%E5%8F%8C%E6%8B%BC
DoubleVowelsToNormal(word, index)
{
    if( word == "" ){
        return ""
    }
    static double_vowels := {"q":["iu"], "w":["ei"], "e":["e"], "r":["uan"], "t":["ue","ve"], "y":["un"], "u":["u"], "i":["i"], "o":["o","ou"], "p":["ie"]
        , "a":["a"], "s":["iong","ong"], "d":["ai"], "f":["en"], "g":["eng"], "h":["ang"], "j":["an"], "k":["ing","uai"], "l":["iang","uang"]
        , "z":["ou"], "x":["ia","ua"], "c":["ao"], "v":["ui","v"], "b":["in"], "n":["iao"], "m":["ian"]}
    Assert(double_vowels.HasKey(word), word)
    return double_vowels[word, index]
}

PinyinSplitterGetDoubleVowels(input_str, initials, ByRef index, prev_splitted_input)
{
    local
    vowels_max_len  := 1
    double_vowels   := ""
    vowels_len      := 0
    if( vowels_max_len > 0 )
    {
        double_vowels := SubStr(input_str, index, 1)
        if( IsVowelsAnyMark(double_vowels) )
        {
            vowels_len += 0
        }
        else
        {
            last_vowels := ""
            loop
            {
                vowels := DoubleVowelsToNormal(double_vowels, A_Index)
                if( last_vowels == vowels || vowels == "" ) {
                    vowels_len += 0
                    break
                }
                if( IsCompletePinyin(initials, vowels) )
                {
                    vowels_len += 1
                    break
                }
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
PinyinSplitterInputStringDouble(input_string)
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
        if( IsInitials(initials) || IsInitialsAnyMark(initials) )
        {
            start_string_index := string_index

            initials    := PinyinSplitterGetInitials(input_string, initials, string_index)
            vowels      := PinyinSplitterGetDoubleVowels(input_string, initials, string_index, prev_splitted_input)
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
