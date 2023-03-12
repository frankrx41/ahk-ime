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

    main := "data\ciku.db"
    extend := "data\ciku_extend.db"
    if (DB._Handle)
        DB.CloseDB()
    DB:="", DB:=new SQLiteDB
    if !DB.OpenDB(main){
        MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
        ExitApp
    }
    DB.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
    DB.CreateScalarFunc("szm", 1, RegisterCallback("shouzimu", "C"))
    DB.CreateScalarFunc("t2s", 1, RegisterCallback("trad2simp", "C"))
    ; DB.CreateScalarFunc("erjiayi", 2, RegisterCallback("erjiayi", "C"))
    DB.Exec("DROP TABLE if EXISTS 'main'.''")
    DB.AttachDB(extend, "extend")
    if (extend!=main)&&DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND tbl_name IN ('English','functions','hotstrings','customs','symbol')",TableInfo){
        Loop % TableInfo.RowCount {
            if (TableInfo.Rows[A_Index,1]="English"), TableName:=TableInfo.Rows[A_Index,1]
                _SQL = CREATE TABLE 'extend'.'English' ("key" TEXT COLLATE NOCASE,"weight" INTEGER DEFAULT 0);
            else if (TableName ~= "functions|hotstrings|symbol|customs")
                _SQL = CREATE TABLE 'extend'.'%TableName%' ("key" TEXT,"value" TEXT,"comment" TEXT);
            if DB.Exec(_SQL)
                DB.Exec("INSERT INTO 'extend'.'" TableName "' SELECT * FROM 'main'.'" TableName "'"), DB.Exec("DROP TABLE 'main'.'" TableInfo.Rows[A_Index, 1] "'")
        }
    }
    return
}
