#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include, ime_assert.ahk
#Include, ime_func.ahk
#Include, ime_db.ahk
#Include, lib\SQLiteDB.ahk
#Include, ime_pinyin_get_result.ahk

WordCreateGui( input_text )
{
    local
    static value, weight, comment
    global create_gui_pinyin_key
    Gui, create:-MinimizeBox
    Gui, create:Font, s12

    Gui, create:Add, Text, , Key:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vcreate_gui_pinyin_key,

    Gui, create:Add, Text, xm, Value:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vvalue, %input_text%

    Gui, create:Add, Text, xm, Comment:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1 vcomment,

    Gui, create:Add, Text, xm, Weight:
    Gui, create:Add, Edit, x80 yp w100 Number vweight
    Gui, create:Add, UpDown, x160 yp w400 Range0-65000, 28000

    Gui, create:Add, Button, x+30 w80, Pinyin
    Gui, create:Add, Button, x+15 Default w80, OK
    Gui, create:Add, Button, yp x+15 w80, Cancel
    Gui, create:Show, , Create Word
    Gosub, createButtonPinyin
    return

    createButtonPinyin:
        Gui, create:Submit, NoHide
        pinyin := GetPinyin(value)
        pinyin := StrReplace(pinyin, " ")
        ; MsgBox, % value "," pinyin "," create_gui_pinyin_key
        GuiControl, create:, create_gui_pinyin_key, %pinyin%
    return

    createButtonOk:
        Gui, create:Submit, NoHide
        ; MsgBox, % create_gui_pinyin_key "," value "," weight "," comment
        if( create_gui_pinyin_key && value && weight ){
            weight := StrReplace(weight, ",")
            global DB
            WordCreateDB(DB, create_gui_pinyin_key, value, weight, comment)
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

WordCreateDB(DB, key, value, weight:=28000, comment:="")
{
    local
    Assert(key && value && weight)

    sim := GetSqlSimpleKey(key)

    sql_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE sim='" sim "' AND key='" key "' AND value='" value "'"

    if( DB.GetTable(sql_cmd, result_table) )
    {
        ; if( !comment ){
        ;     comment = %A_MM%-%A_DD%
        ; }
        if( result_table.RowCount == 0 )
        {
            sql_cmd := "INSERT INTO pinyin ( sim, [key], value, weight, comment ) "
            sql_cmd .= "VALUES ( '" sim "', '" key "', '" value "', " weight ", '" comment "' );"

            ; DB.Exec(sql_cmd)
            if( DB.Exec(sql_cmd) ){
                Msgbox, % "Create success`nKey: " key "`nValue: " value
            } else {
                Assert(0, DB.ErrorMsg,,true)
            }
        } else {
            sql_cmd := "UPDATE pinyin SET sim = '" sim "', [key] = '" key "', value = '" value "', weight = '" weight "', comment = '" comment "' "
            sql_cmd .= "WHERE sim = '" sim "' AND ""key"" = '" key "' AND value = '" value "';"
            
            if( DB.Exec(sql_cmd) ){
                Msgbox, % "Update success`nKey: " key "`nValue: " value
            } else {
                Assert(0, DB.ErrorMsg,,true)
            }
        }
    } else {
        Assert(0, DB.ErrorMsg,,true)
    }
}

GetPinyin(word)
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

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
ImeDBInitialize()

WordCreateGui("")
return
