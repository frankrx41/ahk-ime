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
    if( DB._Handle ){
        DB.CloseDB()
    }
    DB := new SQLiteDB
    path := ".\data\ciku.db"
    if( !DB.OpenDB(path) ){
        MsgBox, 16, Error, % "Message: `t" DB.ErrorMsg "`nCode: `t" DB.ErrorCode
        ExitApp
    }
    return
}
