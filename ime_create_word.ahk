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

WordCreateGui( value := "" )
{
    local
    Gui, create:-MinimizeBox
    Gui, create:Font, s12

    Gui, create:Add, Text, , Key:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1,

    Gui, create:Add, Text, xm, Value:
    Gui, create:Add, Edit, x80 yp w400 -Multi r1, %value%

    Gui, create:Add, Text, xm, Weight:
    Gui, create:Add, Edit, x80 yp w100 Number
    Gui, create:Add, UpDown, x160 yp w400 Range0-65000, 32000

    Gui, create:Add, Button, xm Default w100, OK
    Gui, create:Add, Button, yp x+15 w100, Cancel
    Gui, create:Show, , Create Word
    Return

    createButtonOk:
        MsgBox, Ok
    return

    createGuiEscape:
    createGuiClose:
    createButtonCancel:
        Gui, create:Destroy
    Return
}

WordCreateDB(DB, key, value, weight:=28000)
{
    local
    Assert(key && value && weight)

    sim := GetSqlSimpleKey(key)

    sql_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE sim='" sim "' AND key='" key "' AND value='" value "'"

    if( DB.GetTable(sql_cmd, result_table) )
    {
        comment = %A_MM%-%A_DD%
        if( result_table.RowCount == 0 )
        {
            sql_cmd := "INSERT INTO pinyin ( sim, [key], value, weight, comment ) "
            sql_cmd .= "VALUES ( '" sim "', '" key "', '" value "', " weight ", '" comment "' );"

            ; DB.Exec(sql_cmd)
            if( DB.Exec(sql_cmd) ){
                Msgbox, % "Create success`nKey: " key "`nValue: " value
            } else {
                Assert(0,,,true)
            }
        } else {
            sql_cmd := "UPDATE pinyin SET sim = '" sim "', [key] = '" key "', value = '" value "', weight = '" weight "', comment = '" comment "' "
            sql_cmd .= "WHERE sim = '" sim "' AND ""key"" = '" key "' AND value = '" value "';"
            
            if( DB.Exec(sql_cmd) ){
                Msgbox, % "Update success`nKey: " key "`nValue: " value
            } else {
                Assert(0,,,true)
            }
        }
    } else {
        Assert(0,,,true)
    }
}

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
ImeDBInitialize()
WordCreateDB(DB, "lian3zhao4", "脸照")
WordCreateDB(DB, "shou3ru3", "首乳")
; WordCreateGui("你好")
return

; ExitApp


; pypinyin_exe    := "C:\SDK\Python\Python310\Scripts\pypinyin.exe"

; InputBox, input_text, Create Word, , , 200, 100

; if( !ErrorLevel && input_text ){
;     cmdline := pypinyin_exe . " -s TONE3" . " " . input_text
;     pinyin := CmdRet(cmdline)
;     pinyin := RTrim(pinyin, "`n`r`t ")
;     MsgBox, % pinyin "," input_text

;     InputBox, input_pinyin, Create Word, , , 200, 100

; }

