;*******************************************************************************
; Extern
ImeDBInitialize()
{
    global ime_db := ""
    ImeDBLoadDB("data\dictionary_tone.db")
}

ImeDBGet()
{
    global ime_db
    return ime_db
}

;*******************************************************************************
; Static
ImeDBLoadDB(path)
{
    global ime_db
    global SQLiteDB

    if( ime_db._Handle ){
        ime_db.CloseDB()
    }

    ime_db := new SQLiteDB
    if( !ime_db.OpenDB(path) )
    {
        MsgBox, 16, ime_db Error, % "Msg:`t" ime_db.ErrorMsg "`nCode:`t" ime_db.ErrorCode
        ExitApp
    }

    ime_db.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
    ime_db.Exec("DROP TABLE if EXISTS 'main'.''")
    return
}
