;*******************************************************************************
; Icon
ImeIconSetMode(mode)
{
    local
    static ime_opt_icon_path := "data\ime.icl"
    tooltip_option := "X2300 Y1200"
    if( !mode ){
        ToolTip(4, "", "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 2, 1
    } else {
        switch (mode) {
        case "en": info_text := "英", tooltip_option := tooltip_option . " Q1 B1e1e1e T4f4f4f"
        case "cn": info_text := "中", tooltip_option := tooltip_option . " Q1 Bff4f4f Tfefefe"
        case "tw": info_text := "漢", tooltip_option := tooltip_option . " Q1 B0033cc Tfefefe"
        case "jp": info_text := "日", tooltip_option := tooltip_option . " Q1 B339933 Tfefefe"
        }
        ToolTip(4, info_text, "", tooltip_option)
        Menu, Tray, Icon, %ime_opt_icon_path%, 1, 1
    }
    return
}
