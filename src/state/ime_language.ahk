ImeLanguageInitialize()
{
    global ime_mode_language
    ime_mode_language := "en"         ; "cn", "en", "tw", "jp"
}

;*******************************************************************************
; Mode
ImeLanguageSet(mode)
{
    global ime_mode_language
    switch (mode) {
    case "cn", "en", "tw", "jp":    ime_mode_language := mode
    default:                        ime_mode_language := "en"
    }
}

ImeLanguageGet()
{
    global ime_mode_language
    Assert(ime_mode_language)
    return ime_mode_language
}

ImeLanguageIsEnglish()
{
    global ime_mode_language
    return ime_mode_language == "en"
}

ImeLanguageIsChinese()
{
    global ime_mode_language
    return ImeLanguageIsSimChinese() || ImeLanguageIsTraChinese()
}

ImeLanguageIsSimChinese()
{
    global ime_mode_language
    return ime_mode_language == "cn"
}

ImeLanguageIsTraChinese()
{
    global ime_mode_language
    return ime_mode_language == "tw"
}

ImeLanguageIsJapanese()
{
    global ime_mode_language
    return ime_mode_language == "jp"
}

;*******************************************************************************
;
ImeLanagueUpdate(language)
{
    local
    origin_language := ""
    last_language := ImeLanguageGet()
    if( language != last_language )
    {
        ImeLanguageSet(language)
        if( language != "en" ) {
            origin_language := "en"
        } else {
            origin_language := last_language
        }
    }
    if( language == "tw" )
    {
        PinyinTraditionalInitialize()
    }
    ; Tooltip, % origin_language ", " last_language ", " language
    return origin_language
}
