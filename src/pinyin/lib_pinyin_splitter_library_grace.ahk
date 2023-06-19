;*******************************************************************************
;
PinyinSplitterGetWeight(splitted_string, prev_splitted_input:="")
{
    static splitted_string_weight_table := {}
    Assert(splitted_string, "", false)
    if( prev_splitted_input == "" )
    {
        if( !splitted_string_weight_table.HasKey(splitted_string) )
        {
            ; splitted_string_weight_table[splitted_string] := PinyinSqlGetWeight(splitted_string)
            splitted_string_weight_table[splitted_string] := ImeTranslatorHistoryGetWeight(splitted_string)
        }
        return splitted_string_weight_table[splitted_string]
    }
    else
    {
        return Max(PinyinSplitterGetWeight(prev_splitted_input . splitted_string), PinyinSplitterGetWeight(splitted_string))
    }
}

; [banan]: [nan->ba0nan0(-1)][na->ba0na0(25373)] / [an->ban0an0(26693)]
; [xieru]: [eru] / [ru->xie0ru0(26688)]
; [wanan]: [nan->wa0nan0(-1)][na->wa0na0(23056)] / [an->wan0an0(26606)]
PinyinSplitterCheckIsMaxWeightWord(left_initials, left_vowels, right_string, prev_splitted_input)
{
    right_string_len := StrLen(right_string)
    left_vowels_cut_last := SubStr(left_vowels, 1, StrLen(left_vowels)-1)

    ImeProfilerBegin()
    profile_text := "[" left_initials left_vowels SubStr(right_string, 1, 4) "]: "
    max_word_weight := 0
    result_word := ""

    max_test_len := PinyinSplitterCalcMaxVowelsLength(right_string, 4)
    initials := SubStr(left_vowels, 0, 1)
    loop,
    {
        test_len := max_test_len - A_Index + 1
        if( test_len < 1 || left_vowels_cut_last == "" ) {
            break
        }
        next_char := SubStr(right_string, test_len+1, 1)
        if( next_char == "" || IsMustSplit(next_char) || IsInitials(next_char) )
        {
            test_vowels := SubStr(right_string, 1, test_len)
            profile_text .= "[" initials test_vowels
            if( IsCompletePinyin(initials, test_vowels, "", false) )
            {
                full_vowels := GetFullVowels(initials, test_vowels)
                test_word := left_initials . left_vowels_cut_last "0" initials . full_vowels "0"
                ; if( IsCompletePinyin(left_initials, left_vowels_cut_last) && IsCompletePinyin(initials, full_vowels) )
                word_weight := PinyinSplitterGetWeight(test_word, prev_splitted_input)
                if( word_weight > max_word_weight ){
                    max_word_weight := word_weight
                    result_word := left_initials . left_vowels_cut_last
                }
                profile_text .= "->" test_word "(" word_weight ")"
            }
            profile_text .= "]"
        }
    }

    profile_text .= " / "

    max_test_len := PinyinSplitterCalcMaxVowelsLength(SubStr(right_string, 2), 4)
    initials := SubStr(right_string, 1, 1)
    loop,
    {
        test_len := max_test_len - A_Index + 1
        if( test_len < 1 || left_vowels == "" ) {
            break
        }
        next_char := SubStr(right_string, test_len+2, 1)
        if( next_char == "" || IsMustSplit(next_char) || IsInitials(next_char) )
        {
            test_vowels := SubStr(right_string, 2, test_len)
            profile_text .= "[" initials test_vowels
            if( IsCompletePinyin(initials, test_vowels, "", false) )
            {
                full_vowels := GetFullVowels(initials, test_vowels)
                test_word := left_initials . left_vowels "0" initials . full_vowels "0"
                word_weight := PinyinSplitterGetWeight(test_word, prev_splitted_input)
                if( word_weight > max_word_weight ){
                    max_word_weight := word_weight
                    result_word := left_initials . left_vowels
                }
                profile_text .= "->" test_word "(" word_weight ")"
            }
            profile_text .= "]"
        }
    }

    ImeProfilerEnd(profile_text)

    if( max_word_weight > 0 )
    {
        return (left_initials . left_vowels) == result_word
    }

    first_char := SubStr(right_string, 1, 1)
    if( IsZeroInitials(first_char) ){
        ; TODO: We need to check more vowel
        ; Temporary fix "henexin"
        if( left_initials . left_vowels == "hen" && first_char == "e" ) {
            return true
        }
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
        if( !IsCompletePinyin(left_initials, left_vowels, "'", false) ) {
            return false
        }
        if( !IsInitials(SubStr(left_vowels, 0, 1)) ) {
            return true
        }
        return PinyinSplitterCheckIsMaxWeightWord(left_initials, left_vowels, right_string, prev_splitted_input)
    }
    else
    {
        return true
    }
}
