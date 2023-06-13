ImeThemeInitialize()
{
    local
    global ime_theme_tooltip_option_string  := ""
    global ime_theme_icon_option_string     := ""
    font_size           := 13
    font_family         := "Microsoft_YaHei_Mono" ;"Ubuntu Mono derivative Powerline", "DengXian"
    font_bold           := 0
    use_theme           := 0

    ToolTip(1, "", "", " Q" use_theme " F" font_family " H" font_bold)
    ToolTip(4, "", "", " Q1 S11")

    ime_theme_tooltip_option_string := ""
    ime_theme_tooltip_option_string .= " S" font_size
    ime_theme_tooltip_option_string .= " E5.1.1.1"

    ime_theme_icon_option_string    := " X2300 Y1200 S11 E2.1.1.1 Q1"
}

; https://www.wincalendar.com/Color-Picker
ImeThemeGetTooltipOption()
{
    global ime_theme_tooltip_option_string
    tooltip_option := ""
    if( ImeLanguageIsSimChinese() && ImeSchemeIsPinyinDouble() ){
        tooltip_option .= " Q1 BFFFFFF T111111"
        tooltip_option .= " Q1 B1e1e1e Tccccc1"
        tooltip_option .= " Q1 B373832 Td4d4d4"
    }
    else
    if( ImeLanguageIsTraChinese() && ImeSchemeIsPinyinBopomofo() ){
        tooltip_option .= " Q1 Bd9d9d9 T0033cc"
    }
    else{
        tooltip_option := " Q1 Bccffcc T111111"
        tooltip_option := " Q1 BE6F6DF T565921"
        tooltip_option .= " Q1 Bf9f9f9 T474747"
    }
    return ime_theme_tooltip_option_string . tooltip_option
}

ImeThemeGetIconOption()
{
    global ime_theme_icon_option_string

    if( ImeLanguageIsEnglish() ){
        tooltip_option := " B1e1e1e T4f4f4f"
    }
    if( ImeLanguageIsSimChinese() ){
        if( ImeSchemeIsPinyinDouble() ) {
            tooltip_option := " B373832 Td4d4d4"
        } else {
            tooltip_option := " Bff4f4f Tfefefe"
        }
    }
    if( ImeLanguageIsTraChinese() ){
        if( ImeSchemeIsPinyinBopomofo() ) {
            tooltip_option := " B3366ff Tfefefe"
        } else {
            tooltip_option := " B0033cc Tfefefe"
        }
    }
    if( ImeLanguageIsJapanese() ){
        tooltip_option := " B339933 Tfefefe"
    }

    return ime_theme_icon_option_string . tooltip_option
}

ImeThemeGetIconText()
{
    if( ImeLanguageIsEnglish() ){
        return "En"
    }
    if( ImeLanguageIsSimChinese() ) {
        return "中"
    }
    if( ImeLanguageIsTraChinese() ){
        return "漢"
    }
    if( ImeLanguageIsJapanese() ){
        return "日"
    }
}