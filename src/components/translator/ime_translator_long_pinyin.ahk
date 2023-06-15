ImeTranslatorLongPinyinInitialize()
{
    global translator_long_pinyin_list
    translator_long_pinyin_list := ReadFileToTable("data\dictonary_long_pinyin.asm", "`t", "", "")
}

ImeTranslatorLongPinyinHas(splitted_string)
{
    local
    global translator_long_pinyin_list
    found_value := false
    ImeProfilerBegin()
    time_start  := A_TickCount
    profile_text := splitted_string ": "
    for key, value in translator_long_pinyin_list
    {
        if( IsPinyinSoundLike(splitted_string, key) )
        {
            profile_text .= "->" key
            found_value := true
            break
        }
        if( A_TickCount - time_start > 50 ) {
            profile_text .= "TIME OUT"
            break
        }
    }
    ImeProfilerEnd(profile_text)
    return found_value
}
