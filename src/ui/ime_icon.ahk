;*******************************************************************************
; Icon
ImeIconUpdate(show_icon)
{
    local
    static ime_opt_icon_path := "data\ime.icl"
    tooltip_option := ImeThemeGetIconOption()
    tooltip_text := ImeThemeGetIconText()
    if( !show_icon ){
        ToolTip(4, "", "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        ToolTip(4, tooltip_text, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
