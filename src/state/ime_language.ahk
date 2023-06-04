ImeLanguageInitialize()
{
    global ime_mode_language
    global ime_mode_scheme

    ime_mode_language           := "en"         ; "cn", "en", "tw", "jp"
    ime_mode_scheme             := "normal"     ; "double"
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
    return ime_mode_language
}

ImeLanguageIsEnglish()
{
    global ime_mode_language
    return ime_mode_language == "en"
}

ImeSchemeIsPinyinNormal()
{
    global ime_mode_scheme
    return ime_mode_scheme == "normal"
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
