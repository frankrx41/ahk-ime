; 加载数据库
LoadDB:
    main := "data\ciku.db"
    extend := "data\ciku_extend.db"
    If (DB._Handle)
        DB.CloseDB()
    DB:="", DB:=new SQLiteDB
    If (MemoryDB){
        Suspend, On
        Progress, B2 ZH-1 ZW-1 FS12, 载入内存数据库中，请稍后...
        If !(DB.OpenDB("")&&DB.LoadOrSaveDb(main)){
            MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
            ExitApp
        }
        Suspend, Off
        Progress, Off
    } Else If !DB.OpenDB(main){
        MsgBox, 16, 数据库错误, % "消息:`t" DB.ErrorMsg "`n代码:`t" DB.ErrorCode
        ExitApp
    }
    DB.CreateScalarFunc("REGEXP", 2, RegisterCallback("SQLiteDB_RegExp", "C"))
    DB.CreateScalarFunc("szm", 1, RegisterCallback("shouzimu", "C"))
    DB.CreateScalarFunc("t2s", 1, RegisterCallback("trad2simp", "C"))
    ; DB.CreateScalarFunc("erjiayi", 2, RegisterCallback("erjiayi", "C"))
    DB.Exec("DROP TABLE IF EXISTS 'main'.''")
    DB.AttachDB(extend, "extend")
    If (extend!=main)&&DB.GetTable("SELECT name FROM sqlite_master WHERE type='table' AND tbl_name IN ('English','functions','hotstrings','customs','symbol')",TableInfo){
        Loop % TableInfo.RowCount {
            If (TableInfo.Rows[A_Index,1]="English"), TableName:=TableInfo.Rows[A_Index,1]
                _SQL = CREATE TABLE 'extend'.'English' ("key" TEXT COLLATE NOCASE,"weight" INTEGER DEFAULT 0);
            Else If (TableName ~= "functions|hotstrings|symbol|customs")
                _SQL = CREATE TABLE 'extend'.'%TableName%' ("key" TEXT,"value" TEXT,"comment" TEXT);
            If DB.Exec(_SQL)
                DB.Exec("INSERT INTO 'extend'.'" TableName "' SELECT * FROM 'main'.'" TableName "'"), DB.Exec("DROP TABLE 'main'.'" TableInfo.Rows[A_Index, 1] "'")
        }
    }
Return