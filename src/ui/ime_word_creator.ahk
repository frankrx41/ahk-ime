WordCreatorUI( input_text )
{
    local
    static value, weight
    global word_creator_ui_pinyin_key
    global word_creator_ui_pinyin_weight
    global word_creator_ui_pinyin_comment

    input_text := RegExReplace(input_text, "\s")

    Gui, create:New
    Gui, create:-MinimizeBox
    Gui, create:Font, s12

    Gui, create:Add, Text, , Key:
    Gui, create:Add, Edit, x80 yp w335 -Multi r1 vword_creator_ui_pinyin_key,
    Gui, create:Add, Button, x+5 yp w60, Pinyin

    Gui, create:Add, Text, xm, Value:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vvalue, %input_text%

    Gui, create:Add, Text, xm, Comment:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vword_creator_ui_pinyin_comment,

    Gui, create:Add, Text, xm, Weight:
    Gui, create:Add, Edit, x80 yp w80 Number vword_creator_ui_pinyin_weight
    Gui, create:Add, UpDown, x160 yp w400 Range-1-65000, 28000

    Gui, create:Add, Button, x+5 w60, Reset
    Gui, create:Add, Button, x+5 w60, GetDB
    Gui, create:Add, Button, x+45 Default w70, Update
    Gui, create:Add, Button, yp x+5 w70, Exit
    Gui, create:Show, , Create Word
    Gosub, createButtonPinyin
    return

    createButtonReset:
        GuiControl, create:, word_creator_ui_pinyin_weight, 28,000
    return

    createButtonGetDB:
        Gui, create:Submit, NoHide
        WordCreatorDBGetInfo(ImeDBGet(), word_creator_ui_pinyin_key, value, weight, comment)
        ; Make 1234 -> "1,234"
        if( weight >= 1000 ){
            weight := Floor((weight / 1000)) "," Format("{:03}", Mod(weight, 1000))
        }
        GuiControl, create:, word_creator_ui_pinyin_weight, %weight%
        GuiControl, create:, word_creator_ui_pinyin_comment, %comment%
    return

    createButtonPinyin:
        Gui, create:Submit, NoHide
        pinyin := WordCreatorGetPinyin(value)
        pinyin := StrReplace(pinyin, " ")
        ; MsgBox, % value "," pinyin "," word_creator_ui_pinyin_key
        GuiControl, create:, word_creator_ui_pinyin_key, %pinyin%
    return

    createButtonUpdate:
        Gui, create:Submit, NoHide
        ; MsgBox, % word_creator_ui_pinyin_key "," value "," word_creator_ui_pinyin_weight "," comment
        if( word_creator_ui_pinyin_key && value && word_creator_ui_pinyin_weight ){
            weight := StrReplace(word_creator_ui_pinyin_weight, ",")
            WordCreatorUpdateDB(ImeDBGet(), word_creator_ui_pinyin_key, value, weight, word_creator_ui_pinyin_comment)
        } else {
            MsgBox, Please fill all value
        }
    return

    createGuiEscape:
    createGuiClose:
    createButtonExit:
        Gui, create:Destroy
    return
}

WordCreatorUpdateDB(DB, key, value, weight:=28000, comment:="")
{
    local
    Assert(key && value && weight, "", false)
    weight := Max(0, weight)
    sim := PinyinSqlSimpleKey(key)

    WordCreatorDBGetInfo(DB, key, value, load_weight, load_comment)
    is_create_new_key := (load_weight == -1)
    if( is_create_new_key )
    {
        sql_cmd := "INSERT INTO pinyin ( sim, [key], value, weight, comment ) "
        sql_cmd .= "VALUES ( '" sim "', '" key "', '" value "', " weight ", '" comment "' );"
    }
    else
    {
        sql_cmd := "UPDATE pinyin SET sim = '" sim "', [key] = '" key "', value = '" value "', weight = '" weight "', comment = '" comment "' "
        sql_cmd .= "WHERE sim = '" sim "' AND ""key"" = '" key "' AND value = '" value "';"
    }

    if( DB.Exec(sql_cmd) ){
        msgbox_info := "Key:`t" key "`nValue:`t" value "`nWeight:`t" weight "`nComment: """ comment """ (" Asc(comment) ")"
        if( is_create_new_key ) {
            msgbox_style := 48
            msgbox_title := "Create Success"
        } else {
            msgbox_style := 32
            msgbox_title := "Update Success"
        }
        Msgbox, % msgbox_style, % msgbox_title, % msgbox_info
        ImeTranslatorHistoryClear()
    } else {
        Assert(0, DB.ErrorMsg, true)
    }
}

WordCreatorDBGetInfo(DB, key, value, ByRef weight, ByRef comment)
{
    sim := PinyinSqlSimpleKey(key)
    sql_cmd := "SELECT weight,comment FROM 'pinyin' WHERE sim='" sim "' AND key='" key "' AND value='" value "'"

    weight := -1
    comment := ""
    if( DB.GetTable(sql_cmd, result_table) )
    {
        if( result_table.RowCount != 0 )
        {
            Assert(result_table.RowCount == 1, sql_cmd, true)
            ; Msgbox, % result_table.Rows[1, 1]
            weight := result_table.Rows[1, 1]
            comment := result_table.Rows[1, 2]
        }
    } else {
        Assert(0, DB.ErrorMsg, true)
    }
}

WordCreatorGetPinyin(word)
{
    if( word ){
        pypinyin_cmd := "py -c """
        pypinyin_cmd .= "from pypinyin import pinyin, lazy_pinyin, Style;"
        pypinyin_cmd .= "print(''.join(lazy_pinyin('" word "', style=Style.TONE3, neutral_tone_with_five=True)))"
        pypinyin_cmd .= """"
        pinyin := CmdRet(pypinyin_cmd)
        pinyin := RTrim(pinyin, "`n`r`t ")
        return pinyin
    } else {
        return ""
    }
}
