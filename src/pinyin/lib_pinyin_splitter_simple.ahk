PinyinSplitterInputStringSimple(input_string)
{
    local
    Critical
    ImeProfilerBegin()

    string_index        := 1
    start_string_index  := 1
    strlen              := StrLen(input_string)
    splitter_list       := []
    hope_length_list    := [0]
    escape_string       := ""
    loop
    {
        check_mark := SubStr(input_string, string_index, 1)

        if( string_index > strlen || IsNeedSplit(check_mark) )
        {
            if( escape_string ) {
                make_result := SplitterResultMake(escape_string, 0, "", start_string_index, string_index-1, false)
                splitter_list.Push(make_result)
                escape_string := ""
                hope_length_list.Push(0)
            }
        }

        if( string_index > strlen ) {
            break
        }

        if( IsNeedSplit(check_mark))
        {
            start_string_index := string_index

            if( !IsRepeatMark(check_mark) )
            {
                parsing_length := 0
                if( IsInitialsAnyMark(check_mark) ){
                    initials := "%"
                } else {
                    initials := check_mark
                }
                string_index += 1

                vowels      := "%"
                empty_tone  := IsEmptyTone(SubStr(input_string, string_index, 1))
                tone        := PinyinSplitterParseTone(SubStr(input_string, string_index), parsing_length)
                string_index += parsing_length

                if( !empty_tone ) {
                    radical := PinyinSplitterParseRadical(SubStr(input_string, string_index), parsing_length)
                    string_index += parsing_length
                } else {
                    radical := 0
                }
            }
            else
            {
                string_index += 1
                radical .= check_mark
            }

            make_result := SplitterResultMake(initials . vowels, tone, radical, start_string_index, string_index-1)
            splitter_list.Push(make_result)

            hope_length_list[hope_length_list.Length()] += 1
            if( empty_tone ){
                hope_length_list.Push(0)
            }
        }
        ; ignore
        else
        {
            if( initials == "'" ){
                initials := " "
            }
            string_index += 1
            escape_string .= initials
        }
    }

    PinyinSplitterUpdateHopeLength(splitter_list, hope_length_list)

    ImeProfilerEnd("""" input_string """ -> [" SplitterResultListGetDebugText(splitter_list) "] " "(" splitter_list.Length() ")")
    return splitter_list
}
