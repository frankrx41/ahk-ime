IsGojuonInitials(character)
{
    return InStr("aiueo", character) || InStr("kstcnhfmyrw", character) || character == "n" || InStr("gzjdbp", character) || character == "-" || InStr("lx", character)
}

GojuonSplitterGetVowels(input_str, initials, ByRef index)
{
    have_check := false
    ; aiueo
    if( !have_check && InStr("aiueo", initials) ){
        vowels := ""
        index += 0
        have_check := true
    }
    ; nn
    if( !have_check && initials == "n" && SubStr(input_str, index, 1) == "n"){
        vowels := "n"
        index += 1
        have_check := true
    }
    ; tta ppa
    if( !have_check && InStr("ksthfmyrgzdbpclx", initials) && SubStr(input_str, index, 1) == initials){
        vowels := ""
        index += 0
        have_check := true
    }
    ; shi chi
    if( !have_check && InStr("sc", initials) && SubStr(input_str, index, 1) == "h" ){
        vowels := SubStr(input_str, index, 2)
        index += 2
        have_check := true
    }
    ; tsu
    if( !have_check && initials == "t" && SubStr(input_str, index, 2) == "su" ){
        vowels := "su"
        index += 2
        have_check := true
    }
    ; kya sha
    if( !have_check && InStr("kscnhmrgzjdbp", initials) && RegExMatch(SubStr(input_str, index, 2), "y[auo]") ){
        vowels := SubStr(input_str, index, 2)
        index += 2
        have_check := true
    }
    ; cha
    if( !have_check && InStr("sc", initials) && RegExMatch(SubStr(input_str, index, 2), "h[auo]") ){
        vowels := SubStr(input_str, index, 2)
        index += 2
        have_check := true
    }
    ; ja
    if( !have_check && initials == "j" && InStr("auo", SubStr(input_str, index, 1)) ){
        vowels := SubStr(input_str, index, 1)
        index += 1
        have_check := true
    }
    ; lx
    if( !have_check && InStr("lx", initials) ){
        ; la xa
        if( !have_check && InStr("aiueo", SubStr(input_str, index, 1)) ){
            vowels := SubStr(input_str, index, 1)
            index += 1
            have_check := true
        }
        ; lka
        if( !have_check && RegExMatch(SubStr(input_str, index, 2), "(k[aue]|s[iu]|tu|nu|h[aiueo]|mu|y[auo]|r[aiueo]|wa|pu)") ){
            vowels := SubStr(input_str, index, 2)
            index += 2
            have_check := true
        }
        if( !have_check && RegExMatch(SubStr(input_str, index, 3), "(shi|tsu)") ){
            vowels := SubStr(input_str, index, 3)
            index += 3
            have_check := true
        }
    }
    ; ki
    if( !have_check && InStr("lx", initials) && SubStr(input_str, index, 2) == "ku"){
        vowels := SubStr(input_str, index, 1)
        index += 1
        have_check := true
    }
        if( !have_check && InStr("lx", initials) && SubStr(input_str, index, 2) == "ka"){
        vowels := SubStr(input_str, index, 1)
        index += 1
        have_check := true
    }

    if( !have_check && InStr("kstcnhfmyrwgzjdbp", initials) && InStr("aiueo", SubStr(input_str, index, 1)) ){
        vowels := SubStr(input_str, index, 1)
        index += 1
        have_check := true
    }

    if( !have_check ){
        vowels := ""
        index += 0
        have_check := true
    }

    ; TODO: fa ふぁ la
    ; xtsu xtu ltsu ltu っ

    return vowels
}

GojuonSplitterInputString(input_string)
{
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
        if( IsGojuonInitials(initials) )
        {
            start_string_index := string_index
            vowels      := GojuonSplitterGetVowels(input_string, initials, string_index)

            need_translate := (string_index <= strlen+1)
            make_result := SplitterResultMake(initials . vowels, "", "", start_string_index, string_index-1, need_translate)
            splitter_list.Push(make_result)

            hope_length_list[hope_length_list.Length()] += 1
        }
    }

    splitter_return_list := []
    loop, % splitter_list.Length()
    {
        splitter_result := splitter_list[A_Index]
        pinyin          := SplitterResultGetPinyin(splitter_result)
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

        make_result := SplitterResultMake(pinyin, "", "", start_pos, end_pos, need_translate, hope_length)
        splitter_return_list.Push(make_result)
    }

    return splitter_return_list
}
