WordCreatorUI( input_text )
{
    local
    static value, weight, comment
    global word_creator_ui_pinyin_key
    global word_creator_ui_pinyin_weight

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
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vcomment,

    Gui, create:Add, Text, xm, Weight:
    Gui, create:Add, Edit, x80 yp w100 Number vword_creator_ui_pinyin_weight
    Gui, create:Add, UpDown, x160 yp w400 Range-1-65000, 28000

    Gui, create:Add, Button, x+5 w60, Weight
    Gui, create:Add, Button, x+5 w60, WReset
    Gui, create:Add, Button, x+15 Default w70, OK
    Gui, create:Add, Button, yp x+5 w70, Cancel
    Gui, create:Show, , Create Word
    Gosub, createButtonPinyin
    return

    createButtonWReset:
        GuiControl, create:, word_creator_ui_pinyin_weight, 28,000
    return

    createButtonWeight:
        Gui, create:Submit, NoHide
        weight := WordCreatorDBGetWeight(ImeDBGet(), word_creator_ui_pinyin_key, value)
        ; Make 1234 -> "1,234"
        if( weight >= 1000 ){
            weight := Floor((weight / 1000)) "," Format("{:03}", Mod(weight, 1000))
        }
        GuiControl, create:, word_creator_ui_pinyin_weight, %weight%
    return

    createButtonPinyin:
        Gui, create:Submit, NoHide
        pinyin := WordCreatorGetPinyin(value)
        pinyin := StrReplace(pinyin, " ")
        ; MsgBox, % value "," pinyin "," word_creator_ui_pinyin_key
        GuiControl, create:, word_creator_ui_pinyin_key, %pinyin%
    return

    createButtonOk:
        Gui, create:Submit, NoHide
        ; MsgBox, % word_creator_ui_pinyin_key "," value "," word_creator_ui_pinyin_weight "," comment
        if( word_creator_ui_pinyin_key && value && word_creator_ui_pinyin_weight ){
            weight := StrReplace(word_creator_ui_pinyin_weight, ",")
            WordCreatorUpdateDB(ImeDBGet(), word_creator_ui_pinyin_key, value, weight, comment)
        } else {
            MsgBox, Please fill all value
        }
    return

    createGuiEscape:
    createGuiClose:
    createButtonCancel:
        Gui, create:Destroy
    return
}

WordCreatorUpdateDB(DB, key, value, weight:=28000, comment:="")
{
    local
    Assert(key && value && weight)
    weight := Max(0, weight)
    sim := PinyinSqlSimpleKey(key)

    if( WordCreatorDBGetWeight(DB, key, value) == -1 )
    {
        sql_cmd := "INSERT INTO pinyin ( sim, [key], value, weight, comment ) "
        sql_cmd .= "VALUES ( '" sim "', '" key "', '" value "', " weight ", '" comment "' );"

        if( DB.Exec(sql_cmd) ){
            Msgbox, 48, , % "Create success`nKey: " key "`nValue: " value
        } else {
            Assert(0, DB.ErrorMsg,,true)
        }
    }
    else
    {
        sql_cmd := "UPDATE pinyin SET sim = '" sim "', [key] = '" key "', value = '" value "', weight = '" weight "', comment = '" comment "' "
        sql_cmd .= "WHERE sim = '" sim "' AND ""key"" = '" key "' AND value = '" value "';"
        
        if( DB.Exec(sql_cmd) ){
            Msgbox, 32, , % "Update success`nKey: " key "`nValue: " value
        } else {
            Assert(0, DB.ErrorMsg,,true)
        }
    }
}

WordCreatorDBGetWeight(DB, key, value)
{
    sim := PinyinSqlSimpleKey(key)
    sql_cmd := "SELECT weight FROM 'pinyin' WHERE sim='" sim "' AND key='" key "' AND value='" value "'"

    if( DB.GetTable(sql_cmd, result_table) )
    {
        if( result_table.RowCount != 0 )
        {
            Assert(result_table.RowCount == 1, sql_cmd,,true)
            ; Msgbox, % result_table.Rows[1, 1]
            return result_table.Rows[1, 1]
        }
    } else {
        Assert(0, DB.ErrorMsg,,true)
    }
    return -1
}

WordCreatorGetPinyin(word)
{
    if( word ){
        pypinyin_exe := "C:\SDK\Python\Python310\Scripts\pypinyin.exe"
        cmdline := pypinyin_exe . " -s TONE3" . " " . word
        pinyin := CmdRet(cmdline)
        pinyin := RTrim(pinyin, "`n`r`t ")
        return pinyin
    } else {
        return ""
    }
}
