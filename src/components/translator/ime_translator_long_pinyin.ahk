ImeTranslatorLongPinyinInitialize()
{
    global translator_long_pinyin_list
    translator_long_pinyin_list := ReadFileToTable("data\dictonary_long_pinyin.asm")
}

ImeTranslatorLongPinyinHas(pinyin)
{
    local
    global translator_long_pinyin_list
    found_value := false
    ImeProfilerBegin()
    for key, value in translator_long_pinyin_list
    {
        if( SubStr(pinyin, 1, 1) != SubStr(key, 1, 1) )
        {
            continue
        }
        else
        {
            if( IsPinyinSoundLikeFast(pinyin, key) )
            {
                found_value := true
                break
            }
        }
    }
    ImeProfilerEnd()
    return found_value
}
