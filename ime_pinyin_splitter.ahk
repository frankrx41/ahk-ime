;*******************************************************************************
; Initialize
PinyinSplitterTableInitialize()
{
    ; global splitted_string_weight_table := {}
    ; FileRead, file_content, data\pinyin-split.txt
    ; Loop, Parse, file_content, `n, `r
    ; {
    ;     if( A_LoopField ){
    ;         splitted_string_weight_table[A_LoopField] := 1
    ;     }
    ; }
    ; Assert(splitted_string_weight_table.Count() != 0)
}

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

PinyinSplitterGetWeight(pinyin)
{
    static splitted_string_weight_table := {}
    if( !splitted_string_weight_table.HasKey(pinyin) )
    {
        splitted_string_weight_table[pinyin] := PinyinSqlGetWeight(pinyin)
    }
    return splitted_string_weight_table[pinyin]
}

;*******************************************************************************
; banan -> [ba'nan, ban'an]
; xieru -> [xi'eru, xie'ru]
PinyinSplitterCheckDBWeight(left_initials, left_vowels, right_string)
{
    right_string_len := StrLen(right_string)
    right_initials := SubStr(right_string, 1, 1)
    left_vowels_cut_last := SubStr(left_vowels, 1, StrLen(left_vowels)-1)
    left_vowels_last := SubStr(left_vowels, 0, 1)

    max_test_len := Min(5, right_string_len)
    found := false
    loop, % max_test_len-1
    {
        index := max_test_len - A_Index
        test_right_string := SubStr(right_string, 2, index)
        if( IsCompletePinyin(right_initials, test_right_string) && IsCompletePinyin(left_vowels_last, right_initials . test_right_string) )
        {
            found := true
            break
        }
    }

    if( !found ){
        return true
    }

    word_left := left_initials . left_vowels "0" right_initials . test_right_string "0"
    word_right := left_initials . left_vowels_cut_last "0" left_vowels_last . right_initials . test_right_string "0"

    word_left_weight := PinyinSplitterGetWeight(word_left)
    word_right_weight := PinyinSplitterGetWeight(word_right)
    if( word_left_weight > word_right_weight && word_left_weight >= 0 ){
        return true
    }

    return false
}

PinyinSplitterIsGraceful(left_initials, left_vowels, right_string)
{
    next_char := SubStr(right_string, 1, 1)
    if( !right_string || IsTone(next_char) ){
        return true
    }

    right_initials := SubStr(left_vowels, 0, 1)
    if( right_initials == "?" ){
        return true
    }

    is_complete := 0
    if( next_char == "o" ){
        is_complete += IsCompletePinyin(right_initials, "on")
    }

    if( is_complete || IsCompletePinyin(right_initials, next_char) )
    {
        return PinyinSplitterCheckDBWeight(left_initials, left_vowels, right_string)
    }
    else
    {
        return true
    }
}

PinyinSplitterGetVowels(input_str, initials, ByRef index)
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
                if( next_char == "" || IsRadical(next_char) || IsTone(next_char) || IsSymbol(next_char) ) {
                    break
                }
                if( !IsZeroInitials(initials) && vowels_len == 1 ){
                    break
                }
                if( IsInitials(next_char) && PinyinSplitterIsGraceful(initials, vowels, SubStr(input_str, index+vowels_len)) ) {
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
; "wo3ai4ni3" -> [wo3, ai4, ni3]
; "woaini" -> [wo0, ai0, ni0]
; "wo'ai'ni" -> [wo0, ai0, ni0]
; "wo aini" -> [wo0, ai0, ni0]
; "swalb1" -> [s%0, wa0, l%0, b%1]
; "zhrmghg" -> [zh%0, r%0, m%0, g%0, h%0, g%0]
; "taNde1B" -> [ta0{N}, de1{B}]
; "z?eyangz?i3" -> [z?e0, yang0, z?i3]
;
; See: `PinyinSplitterInputStringTest`
PinyinSplitterInputString(input_string)
{
    local
    Critical
    ImeProfilerBegin(11)

    string_index        := 1
    start_string_index  := 1
    strlen          := StrLen(input_string)
    splitter_result := []
    escape_string   := ""

    splitter_index_list := []

    ; last char * marks simple spell
    auto_complete := (SubStr(input_string, 0, 1) == "*")
    input_string := RTrim(input_string, "*")

    loop
    {
        if( string_index > strlen ) {
            break
        }

        initials := SubStr(input_string, string_index, 1)
        ; 字母，自动分词
        if( IsInitials(initials) )
        {
            if( escape_string ) {
                SplitterResultPush(splitter_result, escape_string, 0, "", start_string_index, string_index-1, true)
                escape_string := ""
            }

            start_string_index := string_index

            initials    := PinyinSplitterGetInitials(input_string, initials, string_index)
            vowels      := PinyinSplitterGetVowels(input_string, initials, string_index)
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
            RegExMatch(SubStr(input_string, string_index), "^([A-Z]+)", radical)
            string_index += StrLen(radical)

            SplitterResultPush(splitter_result, initials . vowels, tone, radical, start_string_index, string_index-1)

            if( tone_string == " " ){
                splitter_index_list_len := splitter_index_list.Length()
                if( splitter_index_list_len ) {
                    for index, value in splitter_index_list {
                        length := splitter_index_list_len - index + 2
                        SplitterResultSetWordLength(splitter_result, value, length)
                    }
                }
                splitter_index_list := []
            } else {
                splitter_index_list.Push(splitter_result.Length())
            }
        }
        ; 忽略
        else
        {
            string_index += 1
            Assert( initials!="'" )
            escape_string .= initials
        }
    }

    if( escape_string ) {
        SplitterResultPush(splitter_result, escape_string, 0, "", start_string_index, string_index-1, true)
        escape_string := ""
    }

    splitter_index_list_len := splitter_index_list.Length()
    if( splitter_index_list_len ) {
        for index, value in splitter_index_list {
            length := splitter_index_list_len - index + 1
            SplitterResultSetWordLength(splitter_result, value, length)
        }
    }

    ImeProfilerEnd(11, """" input_string """ -> [" SplitterResultGetDisplayText(splitter_result) "] " "(" splitter_result.Length() ")")
    return [splitter_result, auto_complete]
}

;*******************************************************************************
; Unit Test
PinyinSplitterInputStringTest()
{
    test_case := ["wo3ai4ni3", "woaini", "wo'ai'ni", "wo aini", "swalb1", "zhrmghg", "taNde1B", "z?eyangz?i3"]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        splitted_return := PinyinSplitterInputString(input_case)
        test_result := splitted_return[1]
        auto_complete := splitted_return[2]
        msg_string .= "`n""" input_case """ -> [" SplitterResultGetDisplayText(test_result) "] (" auto_complete ")"
    }
    MsgBox, % msg_string
}

PinyinSplitterInputStringTest2()
{
    test_case := [ "banan","bingan","canan","changan","change","dingan","dinge","dongan","enai","enen","gangaotai","geren","gongan","hanan","heni","henai","huane","jianao","jine","jingai","jinge","keneg","keneng","keren","kune","nanan","pingan","qiane","qinai","qingan","renao","shanao","shane","tanga","tigong","tiane","wanan","xianai","xieren","xieri","xinai","xinganlin","yanan","yiner","zhenai","zonge","wanou","lianai","bieren" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        splitted_return := PinyinSplitterInputString(input_case)
        test_result := splitted_return[1]
        auto_complete := splitted_return[2]
        msg_string .= "`n""" input_case """ -> [" SplitterResultGetDisplayText(test_result) "] (" auto_complete ")"
    }
    MsgBox, % msg_string
}
