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

    ImeProfilerEnd("SIM: """ input_string """ -> [" SplitterResultListGetDebugText(splitter_return_list) "] " "(" splitter_return_list.Length() ")")
    return splitter_return_list
}
