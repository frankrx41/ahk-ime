ImeModeInitialize()
{
    global ime_mode_language
    global ime_mode_scheme

    ime_mode_language           := "en"         ; "cn", "en", "tw", "jp"
    ime_mode_scheme             := "normal"     ; "double"
}

;*******************************************************************************
; Mode
ImeModeSetLanguage(mode)
{
    global ime_mode_language
    switch (mode) {
    case "cn", "en", "tw", "jp":    ime_mode_language := mode
    default:                        ime_mode_language := "en"
    }
}

ImeModeGetLanguage()
{
    global ime_mode_language
    return ime_mode_language
}

ImeModeIsEnglish()
{
    global ime_mode_language
    return ime_mode_language == "en"
}

ImeModeIsPinyinNormal()
{
    global ime_mode_scheme
    return ime_mode_scheme == "normal"
}

ImeModeIsChinese()
{
    global ime_mode_language
    return ImeModeIsSimChinese() || ImeModeIsTraChinese()
}

ImeModeIsSimChinese()
{
    global ime_mode_language
    return ime_mode_language == "cn"
}

ImeModeIsTraChinese()
{
    global ime_mode_language
    return ime_mode_language == "tw"
}

ImeModeIsJapanese()
{
    global ime_mode_language
    return ime_mode_language == "jp"
}
