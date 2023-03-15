; 加载数据库
ImeDBInitialize()
{
    global DB := ""
    LoadDB()
}

LoadDB()
{
    global DB
    global SQLiteDB

    path := "data\ciku.db"
    if( DB._Handle ){
        DB.CloseDB()
    }

    DB := new SQLiteDB
    if( !DB.OpenDB(path) )
    {
        MsgBox, 16, DB Error, % "Msg:`t" DB.ErrorMsg "`nCode:`t" DB.ErrorCode
        ExitApp
    }

    DB.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
    DB.Exec("DROP TABLE if EXISTS 'main'.''")
    return
}
