PinyinSqlGetResult(DB, input_str, limit_num:=100)
{
    local
    Critical
    global tooltip_debug

    orgin_str := input_str
    ystr := Trim(input_str, "'")
    rstr := ""

    input_str := Trim(input_str, "'")
    input_str := StrReplace(input_str, "'", "_")
    input_str := StrReplace(input_str, "on'", "ong'")
    tstr := Trim(RegExReplace(input_str, "([a-z]h?)[a-gi-z]+", "$1", nCount), "'")
    tstr := RegExReplace(tstr, "([csz])h", "$1")

    if( nCount ){
        rstr := RegExReplace(input_str, "'([^aoe]h?)'", "'$1[a-z]*'")
    } 
    else
    {
        tRegEx := ""
        for _,key in ["c","s","z"] {
            if InStr(input_str,key "h") {
                tRegEx .= key
            }
        }
        if( tRegEx ){
            rstr := RegExReplace(input_str, "'([^aoe]h?)'", "'$1[a-z]*'")
            if( StrLen(tstr)==1 )
                limit_num:=100
        }
    }

    if (rstr=="") {
        if (input_str~="^''[aoe](''[aoe])*''$") {
            rstr:=input_str
        } else {
            limit_num:=100
        }
    }

    if( !InStr("_12345", SubStr(rstr, 0, 1)) ){
        rstr .= "%"
    }
    if( !InStr("_12345", SubStr(tstr, 0, 1)) ){
        tstr .= "_"
    }

    rstr := Trim(rstr,"'")
    zero_initials_table:="o"

    if( rstr~="[\.\*\?\|\[\]]" )
    {
        _SQL:="jp='" tstr "' AND key REGEXP '^" rstr "$' ORDER BY weight DESC" (limit_num?" LIMIT " limit_num:"")
    }
    else
    {
        _SQL:="jp LIKE '" tstr "'" (rstr?" AND key LIKE '" rstr "'":"") " ORDER BY weight DESC" (limit_num?" LIMIT " limit_num:"")
        ; _SQL:="jp='" tstr "'" (rstr?" AND key='" rstr "'":"") " ORDER BY weight DESC" (limit_num?" LIMIT " limit_num:"")
    }

    tooltip_debug[3] .= "`n[" ystr "]: """ _SQL
    if( DB.GetTable("SELECT key,value,weight FROM 'pinyin' WHERE " _SQL, result_table) )
    {
        ; result_table.Rows = [
        ;   ["wu'hui", "舞会", "30000"]
        ;   ["wu'hui", "误会", "26735"]
        ; ]

        if( result_table.RowCount )
        {
            loop % result_table.RowCount {
                result_table.Rows[A_Index, -1] := ystr
                result_table.Rows[A_Index, 0] := "pinyin|" A_Index
                result_table.Rows[A_Index, 4] := result_table.Rows[1, 3]
            }
        }
        result_table.Rows[0] := ystr
        ; result_table.Rows = [
        ;   [0]: "wu'hui"
        ;        ; -1     , 0         , 1
        ;   [1]: ["wu'hui", "pinyin|1", "wu'hui", "舞会", "30000", "30000"]
        ;   [2]: ["wu'hui", "pinyin|2", "wu'hui", "误会", "26735", "30000"]
        ; ]

        tooltip_debug[3] .= """->(" result_table.RowCount ")"
        ; tooltip_debug[3] .= "`n" ystr "," rstr ": " result_table.RowCount " (" orgin_str ")" "`n" _SQL "`n" CallStack(1)
        return result_table.Rows
    } else {
        return []
    }
}
