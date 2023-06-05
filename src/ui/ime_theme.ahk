ImeThemeInitialize(dark:=false)
{
    local
    global ime_theme_tooltip_option_string  := ""
    global ime_theme_icon_option_string     := ""
    font_size           := 13
    font_family         := "Microsoft_YaHei_Mono" ;"Ubuntu Mono derivative Powerline", "DengXian"
    font_bold           := 0
    if( dark ) {
        ; background_color    := "1e1e1e"
        ; text_color          := "ccccc1"
        background_color    := "373832"
        text_color          := "d4d4d4"
        use_theme           := 1
    } else {
        background_color    := "f9f9f9"
        text_color          := "575757"
        ; background_color    := "FFFFFF"
        ; text_color          := "111111"
        use_theme           := 0
    }

    ToolTip(1, "", "", " Q" use_theme " B" background_color " T" text_color " F" font_family " H" font_bold)
    ToolTip(4, "", "", " Q1 S11")

    ime_theme_tooltip_option_string := ""
    ime_theme_tooltip_option_string .= " S" font_size
    ime_theme_tooltip_option_string .= " E5.1.1.1"

    ime_theme_icon_option_string    := " X2300 Y1200 S11 E2.1.1.1"
}

ImeThemeGetTooltipOption()
{
    global ime_theme_tooltip_option_string
    return ime_theme_tooltip_option_string
}

ImeThemeGetIconOption(mode)
{
    global ime_theme_icon_option_string
    tooltip_option := ""
    switch (mode) {
    case "en": tooltip_option := " Q1 B1e1e1e T4f4f4f"
    case "cn": tooltip_option := " Q1 Bff4f4f Tfefefe"
    case "tw": tooltip_option := " Q1 B0033cc Tfefefe"
    case "jp": tooltip_option := " Q1 B339933 Tfefefe"
    }
    return ime_theme_icon_option_string . tooltip_option
}
