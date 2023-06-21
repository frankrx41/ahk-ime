;*******************************************************************************
;
NormalToNormal(word, index)
{
    return word
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

        if( string_index > strlen || IsNeedSplit(check_mark) )
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

        if( IsNeedSplit(check_mark) )
        {
            start_string_index := string_index
            if( !IsRepeatMark(check_mark) )
            {
                parsing_length  := 0
                initials    := PinyinSplitterParseInitials(SubStr(input_string, string_index), parsing_length)
                string_index += parsing_length

                vowels      := PinyinSplitterParseVowels(SubStr(input_string, string_index), initials, prev_splitted_input, parsing_length)
                full_vowels := GetFullVowels(initials, vowels)
                vowels      := full_vowels ? full_vowels : vowels
                string_index += parsing_length

                empty_tone  := IsEmptyTone(SubStr(input_string, string_index, 1))
                tone        := PinyinSplitterParseTone(SubStr(input_string, string_index), parsing_length)
                string_index += parsing_length

                ; Assert( !(!InStr(vowels, "%") && !IsCompletePinyin(initials, vowels, tone)) )
                if( !empty_tone ) {
                    radical := PinyinSplitterParseRadical(SubStr(input_string, string_index), parsing_length)
                    string_index += parsing_length
                } else {
                    radical := ""
                }
            } else {
                string_index += 1
                empty_tone := false
                radical .= check_mark
            }

            make_result := SplitterResultMake(initials . vowels, tone, radical, start_string_index, string_index-1)
            splitter_list.Push(make_result)

            prev_splitted_input := initials . vowels . tone

            hope_length_list[hope_length_list.Length()] += 1
            if( empty_tone ){
                hope_length_list.Push(0)
            }
        }
        ; Ignore
        else
        {
            if( check_mark == "'" ){
                check_mark := " "
            }
            string_index += 1
            escape_string .= check_mark
        }
    }

    PinyinSplitterUpdateHopeLength(splitter_list, hope_length_list)

    ImeProfilerEnd("""" input_string """ -> [" SplitterResultListGetDebugText(splitter_list) "] " "(" splitter_list.Length() ")")
    return splitter_list
}
