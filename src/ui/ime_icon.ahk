;*******************************************************************************
; Icon
ImeIconSetMode(mode)
{
    local
    static ime_opt_icon_path := "data\ime.icl"
    tooltip_option := ImeThemeGetIconOption(mode)
    if( !mode ){
        ToolTip(4, "", "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        switch (mode) {
        case "en": info_text := "英"
        case "cn": info_text := "中"
        case "tw": info_text := "漢"
        case "jp": info_text := "日"
        }
        ToolTip(4, info_text, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
