;*******************************************************************************
; https://zh.wikipedia.org/wiki/%E5%8F%8C%E6%8B%BC
; index == 0 Get initials
; index >= 1 Get vowels
DoubleToNormal(word, index)
{
    if( word == "" ){
        return ""
    }
    index += 1
    ; 小鹤双拼
    static double_xiaohe := {"q":["q","iu"], "w":["w","ei"], "e":["","e"], "r":["r","uan"], "t":["t","ue","ve"], "y":["y","un"], "u":["sh","u"], "i":["ch","i"], "o":["","o","ou"], "p":["p","ie"]
        , "a":["","a"], "s":["s","iong","ong"], "d":["d","ai"], "f":["f","en"], "g":["g","eng"], "h":["h","ang"], "j":["j","an"], "k":["k","ing","uai"], "l":["l","iang","uang"]
        , "z":["z","ou"], "x":["x","ia","ua"], "c":["c","ao"], "v":["zh","ui","v"], "b":["b","in"], "n":["n","iao"], "m":["m","ian"]}
    ; 自然码双拼
    static double_ziranma := {"q":["q","iu"], "w":["w","ia","ua"], "e":["","e"], "r":["r","uan"], "t":["t","ue","ve"], "y":["y","ing","uai"], "u":["sh","u"], "i":["ch","i"], "o":["","o","ou"], "p":["p","un"]
        , "a":["","a"], "s":["s","iong","ong"], "d":["d","iang","uang"], "f":["f","en"], "g":["g","eng"], "h":["h","ang"], "j":["j","an"], "k":["k","ao"], "l":["l","ai"]
        , "z":["z","ei"], "x":["x","ie"], "c":["c","iao"], "v":["zh","ui","v"], "b":["b","ou"], "n":["n","in"], "m":["m","ian"]}
    ; 拼音加加
    static double_pinyinpp := {"q":["q","er","ing"], "w":["w","ei"], "e":["","e"], "r":["r","en"], "t":["t","eng"], "y":["y","iong","ong"], "u":["ch","u"], "i":["sh","i"], "o":["","o","uo"], "p":["p","ou"]
        , "a":["","a"], "s":["s","ai"], "d":["d","ao"], "f":["f","an"], "g":["g","ang"], "h":["h","iang","uang"], "j":["j","ian"], "k":["k","oao"], "l":["l","in"]
        , "z":["z","un"], "x":["x","uai","ue"], "c":["c","uan"], "v":["zh","ui","v"], "b":["b","ia","ua"], "n":["n","iu"], "m":["m","ie"]}
    ; 紫光拼音
    static double_ziguang := {"q":["q","ao"], "w":["w","en"], "e":["","e"], "r":["r","an"], "t":["t","eng"], "y":["y","in","uai"], "u":["zh","u"], "i":["sh","i"], "o":["","o","uo"], "p":["p","ai"]
        , "a":["ch","a"], "s":["s","ang"], "d":["d","ie"], "f":["f","ian"], "g":["g","iang","uang"], "h":["h","iong","ong"], "j":["j","er","iu"], "k":["k","ei"], "l":["l","uan"], ";":["","ing"]
        , "z":["z","ou"], "x":["x","ia","ua"], "c":["c"], "v":["","v"], "b":["b","iao"], "n":["n","ue","ui"], "m":["m","un"]}
    ; 搜狗拼音
    static double_sougou := {"q":["q","iu"], "w":["w","ia","ua"], "e":["","e"], "r":["r","er","uan"], "t":["t","ue","ve"], "y":["y","uai","v"], "u":["sh","u"], "i":["ch","i"], "o":["","o","uo"], "p":["p","un"]
        , "a":["","a"], "s":["s","iong","ong"], "d":["d","iang","uang"], "f":["f","en"], "g":["g","eng"], "h":["h","ang"], "j":["j","an"], "k":["k","ao"], "l":["l","ai"], ";":["","ing"]
        , "z":["z","ei"], "x":["x","ie"], "c":["c","iao"], "v":["zh","ui"], "b":["b","ou"], "n":["n","in"], "m":["m","ian"]}
    ; 微软拼音
    static double_microsoft := {"q":["q","iu"], "w":["w","ia","ua"], "e":["","e"], "r":["r","er","uan"], "t":["t","ue"], "y":["y","uai","v"], "u":["sh","u"], "i":["ch","i"], "o":["","o","uo"], "p":["p","un"]
        , "a":["","a"], "s":["s","iong","ong"], "d":["d","iang","uang"], "f":["f","en"], "g":["g","eng"], "h":["h","ang"], "j":["j","an"], "k":["k","ao"], "l":["l","ai"], ";":["","ing"]
        , "z":["z","ei"], "x":["x","ie"], "c":["c","iao"], "v":["zh","ui","ve"], "b":["b","ou"], "n":["n","in"], "m":["m","ian"]}
    ; 智能 ABC
    static double_smart_abc := {"q":["q","ei"], "w":["w","ian"], "e":["ch","e"], "r":["r","er","iu"], "t":["t","iang","uang"], "y":["y","ing"], "u":["","u"], "i":["","i"], "o":["","o","uo"], "p":["p","uan"]
        , "a":["zh","a"], "s":["s","iong","ong"], "d":["d","ia","ua"], "f":["f","en"], "g":["g","eng"], "h":["h","ang"], "j":["j","an"], "k":["k","ao"], "l":["l","ai"], ";":["",""]
        , "z":["z","iao"], "x":["x","ie"], "c":["c","in","uai"], "v":["sh","v","ve"], "b":["b","ou"], "n":["n","un"], "m":["m","ue","ui"]}
    ; 中华人民共和国国家标准
    static double_chinese := {"q":["q","ia","ua"], "w":["w","uan","van"], "e":["","e"], "r":["r","en"], "t":["t","ie"], "y":["y","iu","uai"], "u":["sh","u"], "i":["ch","i"], "o":["","o","uo"], "p":["p","ou"]
        , "a":["'","a"], "s":["s","iong","ong"], "d":["d","ian"], "f":["f","an"], "g":["g","ang"], "h":["h","eng"], "j":["j","ing"], "k":["k","ai"], "l":["l","er","in"], ";":["",""]
        , "z":["z","un","vn"], "x":["x","ue","ve"], "c":["c","ao"], "v":["zh","v","vi"], "b":["b","ei"], "n":["n","iang","uang"], "m":["m","iao"]}
    double_pinyin := double_sougou
    Assert(double_pinyin.HasKey(word), word)
    return double_pinyin[word, index]
}

PinyinSplitterGetDoubleInitials(input_str, double_initials, ByRef index)
{
    local
    index += 1

    initials := DoubleToNormal(double_initials, 0)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", double_initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("zcs", double_initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}

PinyinSplitterGetDoubleVowels(input_str, initials, ByRef index, prev_splitted_input)
{
    local

    double_vowels   := ""
    vowels_len      := 0

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
            vowels := DoubleToNormal(double_vowels, A_Index)
            if( last_vowels == vowels || vowels == "" ) {
                vowels_len += 0
                break
            }
            if( initials )
            {
                if( IsCompletePinyin(initials, vowels) )
                {
                    vowels_len += 1
                    break
                }
            }
            else
            {
                if( IsCompletePinyin(vowels, "") )
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
    else if( initials )
    {
        if( !IsCompletePinyin(initials, vowels) ){
            vowels .= "%"
        }
    }
    else
    {
        if( !IsCompletePinyin(vowels, "") ){
            vowels .= "%"
        }
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
        double_initials := SubStr(input_string, string_index, 1)
        initials := DoubleToNormal(double_initials, 0)

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
        if( IsInitials(initials) || IsInitialsAnyMark(initials) || double_initials == "o" )
        {
            start_string_index := string_index

            initials    := PinyinSplitterGetDoubleInitials(input_string, double_initials, string_index)
            vowels      := PinyinSplitterGetDoubleVowels(input_string, initials, string_index, prev_splitted_input)
            full_vowels := GetFullVowels(initials, vowels)
            tone_string := SubStr(input_string, string_index, 1)
            tone        := PinyinSplitterGetTone(input_string, initials, vowels, string_index)

            if( !InStr(vowels, "%") ) {
                if( initials ) {
                    if( !IsCompletePinyin(initials, vowels, tone) ){
                        vowels .= "%"
                    }
                } else {
                    if( !IsCompletePinyin(vowels, "", tone) ){
                        vowels .= "%"
                    }
                }
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
            if( double_initials == "'" ){
                double_initials := " "
            }
            string_index += 1
            escape_string .= double_initials
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
