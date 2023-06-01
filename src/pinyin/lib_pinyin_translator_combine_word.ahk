SoundSplit(pinyin)
{
    array := []
    position := 0
    loop, Parse, pinyin, % "012345"
    {
        ; Calculate the position of the delimiter at the end of this field.
        position += StrLen(A_LoopField) + 1
        ; Retrieve the delimiter found by the parsing loop.
        delimiter := SubStr(pinyin, position, 1)
        if( A_LoopField ) {
            array.Push(A_LoopField . delimiter)
        }
    }
    return array
}

; wo3de5 - wo0de0
IsSoundLike(standard_pinyin, test_pinyin)
{
    speech_array := SoundSplit(standard_pinyin)
    sounds_array := SoundSplit(test_pinyin)

    loop_count := speech_array.Length()
    Assert(sounds_array.Length() == speech_array.Length(), test_pinyin "," standard_pinyin)

    loop, % loop_count
    {
        speech_i := speech_array[A_Index]
        sounds_i := sounds_array[A_Index]

        speech_pinyin   := SubStr(speech_i, 1, StrLen(speech_i)-1)
        speech_tone     := SubStr(speech_i, 0, 1)

        sounds_pinyin   := SubStr(sounds_i, 1, StrLen(sounds_i)-1)
        sounds_tone     := SubStr(sounds_i, 0, 1)

        ; TODO: check this
        speech_pinyin   := RegexReplace(speech_pinyin, "([zcs])\?", "$1", replace_count)
        if( replace_count )
        {
            sounds_pinyin := RegexReplace(speech_pinyin, "([zcs])h", "$1")
        }

        speech_pinyin   := StrReplace(speech_pinyin, "+", ".*")

        if( !RegExMatch(sounds_pinyin, speech_pinyin) )
        {
            return false
        }

        if( speech_tone != sounds_tone )
        {
            if( speech_tone != "0" )
            {
                if( sounds_tone == "5" )
                {
                    if( speech_tone != "1" )
                    {
                        return false
                    }
                }
            }
        }
    }
    return true
}

GetWordMatchLength(pinyin)
{
    RegExReplace(pinyin, "[12345]", "", tone_count)
    return tone_count
}

GetWordFullLength(pinyin)
{
    RegExReplace(pinyin, "[012345]", "", tone_count)
    return tone_count
}

; A-XY-B
PinyinTranslatorInsertCombineWordMatchAt(ByRef translate_result_list, splitter_result_list, match_pinyin, match_word_length, xy_start_index, word_xy_length)
{
    result := false
    Assert( match_word_length == GetWordMatchLength(match_pinyin), match_pinyin ":" match_word_length )
    Assert( word_xy_length == GetWordFullLength(match_pinyin), match_pinyin ":" word_xy_length )

    ; RegExReplace(match_pinyin, "[012345]",, match_word_length)
    test_match_pinyin := SplitterResultListConvertToString(splitter_result_list, xy_start_index, word_xy_length)
    profile_text := ImeProfilerBegin(26)
    profile_text .= "`n  - " match_pinyin "/" test_match_pinyin ": "
    if( IsSoundLike(match_pinyin, test_match_pinyin) )
    {
        splitted_string_ab := ""
        splitted_string_ab .= SplitterResultListConvertToString(splitter_result_list, 1, xy_start_index-1)
        splitted_string_ab .= SplitterResultListConvertToString(splitter_result_list, xy_start_index+word_xy_length)
        ImeTranslatorHistoryUpdateKey(splitted_string_ab)
        profile_text .= "(" splitted_string_ab ")"
        word_ab := ImeTranslatorHistoryGetResultWord(splitted_string_ab)
        if( word_ab ){
            profile_text .= word_ab
            splitted_string_xy := SplitterResultListConvertToString(splitter_result_list, xy_start_index, word_xy_length)
            ImeTranslatorHistoryUpdateKey(splitted_string_xy)
            profile_text .= ", (" splitted_string_xy ")"
            word_xy := ImeTranslatorHistoryGetResultWord(splitted_string_xy)
            if( !word_xy )
            {
                loop, % word_xy_length
                {
                    splitted_string_xy := SplitterResultListConvertToString(splitter_result_list, xy_start_index+A_Index-1, 1)
                    ImeTranslatorHistoryUpdateKey(splitted_string_xy)
                    word_xy .= ImeTranslatorHistoryGetResultWord(splitted_string_xy)
                }
            }
            if( word_xy )
            {
                profile_text .= ", " word_xy
                full_word := SubStr(word_ab, 1, 1) . word_xy . SubStr(word_ab, 2)

                total_word_length := splitter_result_list.Length()
                pinyin := SplitterResultListConvertToString(splitter_result_list, 1, total_word_length)
                single_result := TranslatorResultMake(pinyin, full_word, 0, "auto", total_word_length)
                translate_result_list.InsertAt(1, single_result)
                result := true
            }
        }
    }
    ImeProfilerEnd(26, profile_text)
    return result
}

PinyinTranslatorInsertCombineWord(ByRef translate_result_list, splitter_result_list)
{
    splitter_result_list := SplitterResultListGetUntilLength(splitter_result_list)
    splitted_string := SplitterResultListConvertToString(splitter_result_list, 1, 0)
    if( ImeTranslatorHistoryHasResult(splitted_string) ){
        return
    }

    profile_text := ImeProfilerBegin(25)
    if( splitter_result_list.Length() >= 4 )
    {
        ; 了个 了会 了朵 了顿
        PinyinTranslatorInsertCombineWordMatchAt(translate_result_list, splitter_result_list, "le5+0", 1, 2, 2)

        ; 了
        PinyinTranslatorInsertCombineWordMatchAt(translate_result_list, splitter_result_list, "le5", 1, 2, 1)

        ; 生我的气
        PinyinTranslatorInsertCombineWordMatchAt(translate_result_list, splitter_result_list, "wo3de5", 2, 2, 2)

        ; 他/她
        PinyinTranslatorInsertCombineWordMatchAt(translate_result_list, splitter_result_list, "ta1de5", 2, 2, 2)
    }
    if( splitter_result_list.Length() == 3 )
    {
        ; 陪了他
        PinyinTranslatorInsertCombineWordMatchAt(translate_result_list, splitter_result_list, "le5", 1, 2, 1)
    }

    ImeProfilerEnd(25, profile_text)
}
