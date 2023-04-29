IsSoundLike(speech, sounds_to)
{
    sounds_pinyin   := SubStr(sounds_to, 1, StrLen(sounds_to)-1)
    sounds_tone     := SubStr(sounds_to, 0, 1)

    speech_pinyin   := SubStr(speech, 1, StrLen(speech)-1)
    speech_tone     := SubStr(speech, 0, 1)

    ; TODO: check this
    speech_pinyin   := RegexReplace(speech_pinyin, "([zcs])\?", "$1", replace_count)
    if( replace_count )
    {
        sounds_pinyin := RegexReplace(speech_pinyin, "([zcs])h", "$1")
    }

    speech_pinyin   := StrReplace(speech_pinyin, "?", ".")
    speech_pinyin   := StrReplace(speech_pinyin, "%", ".*")

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

    return true
}

; A-XY-B
PinyinTranslatorInsertCombineWordMatchAt(ByRef translate_result, splitter_result, match_pinyin, xy_start_index, word_xy_length)
{
    RegExReplace(match_pinyin, "[012345]",, match_word_length)
    try_match_pinyin := SplitterResultConvertToString(splitter_result, xy_start_index, match_word_length)
    if( IsSoundLike(try_match_pinyin, match_pinyin) )
    {
        splitted_string_ab := ""
        splitted_string_ab .= SplitterResultConvertToString(splitter_result, 1, xy_start_index-1)
        splitted_string_ab .= SplitterResultConvertToString(splitter_result, xy_start_index+word_xy_length)
        TranslatorHistoryUpdateKey(splitted_string_ab, splitter_result.Length()-word_xy_length)

        word_ab := TranslatorHistoryGetResultWord(splitted_string_ab)
        if( word_ab ){
            splitted_string_xy := SplitterResultConvertToString(splitter_result, xy_start_index, word_xy_length)
            TranslatorHistoryUpdateKey(splitted_string_xy, word_xy_length)
            word_xy := TranslatorHistoryGetResultWord(splitted_string_xy)
            full_word := SubStr(word_ab, 1, 1) . word_xy . SubStr(word_ab, 2)

            total_word_length := splitter_result.Length()
            pinyin := SplitterResultConvertToString(splitter_result, 1, total_word_length)
            single_result := TranslatorSingleResultMake(pinyin, full_word, 0, "auto", total_word_length)
            translate_result.InsertAt(1, single_result)
        }
    }
}

PinyinTranslatorInsertCombineWord(ByRef translate_result, splitter_result)
{
    splitter_result := SplitterResultGetUntilLength(splitter_result)
    splitted_string := SplitterResultConvertToString(splitter_result, 1, 0)
    if( TranslatorHistoryHasResult(splitted_string) ){
        return
    }

    profile_text := ImeProfilerBegin(22)
    if( splitter_result.Length() >= 4 )
    {
        ; 了个 了会 了朵 了顿
        PinyinTranslatorInsertCombineWordMatchAt(translate_result, splitter_result, "le5", 2, 2)

        ; 生我的气
        PinyinTranslatorInsertCombineWordMatchAt(translate_result, splitter_result, "wo3", 2, 2)

        ; 他/她
        PinyinTranslatorInsertCombineWordMatchAt(translate_result, splitter_result, "ta1", 2, 2)
    }
    ImeProfilerEnd(22, profile_text)
}
