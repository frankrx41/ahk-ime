; index == 0 Get initials
; index >= 1 Get vowels
; http://www.sora-as.jp/pinyin/pinyin.html
;
; [Q] [W] [E] [R] [T] [Y] [ ] [ ] [O] [P]
;  [A] [S] [D] [F] [G] [H] [J] [K] [L]
;   [Z] [X] [C] [YU] [B] [N] [M]
;
; [zh] = [z] + [h]
;
; 声母
; [b] [p] [m] [f]
; [d] [t] [n] [l]
; [g] [k] [h]
; [j] [q] [x]
; [zh] [ch] [sh] [r]
; [z] [c] [s]
;
; 韵母
; [a] [o] [e] [i] [u]
; [ai] [ei]
; [ao] [ou]
; [an] [en]
; [ang] [eng] [ong]
; [ia] [iao] [ie] [iou/iu] [ian] [iang] [ing] [iong]
; [ua] [uo] [uai] [uei/ui] [uan] [uen/un] [uang] [ueng]
; [ve] [uan] [un]
;
; https://youtu.be/seaPXehN6no?t=291
; [in] = [i][en]
; [ing] = [i][eng]
; [un] = [v][en]
; [iong] = [v][eng]
; [ong] = [u][eng]
;
; y = i, w = u, yu = v
;
FluentToNormal(word, index)
{
    if( word == "" || word == " " ){
        return ""
    }

    index += 1
    static fluent_pinyin := {"q":["q"], "w":["w"], "e":["e","e"], "r":["r"], "t":["t"], "y":["y"], "u":["","u"], "i":["","i"], "o":["o","o","ou","iu"], "p":["p","eng"]
        , "a":["a","a"], "s":["s"], "d":["d"], "f":["f"], "g":["g"], "h":["h"], "j":["j","ai"], "k":["k","ei","ui"], "l":["l","ao"]
        , "z":["z"], "x":["x"], "c":["c"], "v":["yu","v"], "b":["b","an"], "n":["n","en","in","nu"], "m":["m","ang"]}

    normal_words := ""
    loop, Parse, word
    {
        test_word := A_LoopField
        ; `. ""` to force as string
        ; Assert(fluent_pinyin.HasKey(test_word . ""), test_word ", " word)

        normal_word := fluent_pinyin[test_word . "", index]
        if( !normal_word ) {
            return ""
        }
        normal_words .= normal_word
    }
    return normal_words
}

PinyinSplitterGetFluentInitials(input_str, fluent_initials, ByRef index)
{
    local
    index += 1

    initials := FluentToNormal(fluent_initials, 0)
    if( IsInitialsAnyMark(initials) ){
        initials := "%"
    }
    if( InStr("zcs", fluent_initials) && (SubStr(input_str, index, 1)=="h") ){
        ; zcs + h
        index += 1
        initials .= "h"
    }
    if( InStr("zcs", fluent_initials) && (SubStr(input_str, index, 1)=="?") ){
        index += 1
        initials .= "?"
    }
    initials := Format("{:L}", initials)
    return initials
}

PinyinSplitterCalcFluentMaxVowelsLength(input_str, index)
{
    local
    strlen := StrLen(input_str)
    vowels_max_len := 0
    loop {
        ; Max len is 3
        if( vowels_max_len >= 3 || index+vowels_max_len-1>=strlen ){
            break
        }
        check_fluent_char := SubStr(input_str, index+vowels_max_len, 1)
        check_char := FluentToNormal(check_fluent_char, 0)
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

PinyinSplitterGetFluentVowels(input_str, initials, ByRef index, prev_splitted_input)
{
    local
    vowels_max_len  := PinyinSplitterCalcFluentMaxVowelsLength(input_str, index)
    fluent_vowels := ""
    vowels_len      := 0
    found_vowels    := false
    vowels          := ""
    if( vowels_max_len > 0 )
    {
        loop
        {
            vowels_len := vowels_max_len+1-A_Index
            fluent_vowels := SubStr(input_str, index, vowels_len)
            if( IsVowelsAnyMark(fluent_vowels) )
            {
                break
            }
            else
            {
                last_vowels := ""
                loop
                {
                    vowels := FluentToNormal(fluent_vowels, A_Index)
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
PinyinSplitterInputStringFluent(input_string)
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
        fluent_initials := SubStr(input_string, string_index, 1)
        initials := FluentToNormal(fluent_initials, 0)

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

            initials    := PinyinSplitterGetFluentInitials(input_string, fluent_initials, string_index)
            vowels      := PinyinSplitterGetFluentVowels(input_string, initials, string_index, prev_splitted_input)
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
