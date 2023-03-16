; Get the reseult from database
; Input string origin_input must not content "|"
; Please spilt raw input by space then use this to get result
PinyinSqlGetResult(DB, origin_input, limit_num:=100)
{
    local
    Critical
    global tooltip_debug

    origin_input   := LTrim(origin_input, "'")
    input_str   := origin_input

    Assert(!InStr(origin_input, "|"))

    full_key    := ""

    input_str   := StrReplace(input_str, "'", "_")

    input_str   := StrReplace(input_str, "on'", "ong'")
    sim_key     := Trim(RegExReplace(input_str, "([a-z]h?)[a-gi-z]+", "$1", word_count), "'")
    sim_key     := RegExReplace(sim_key, "([csz])h", "$1")
    if( !InStr("_12345", SubStr(sim_key, 0, 1)) ){
        sim_key .= "_"
    }

    if( word_count ){
        full_key := RegExReplace(input_str, "'([^aoe]h?)'", "'$1[a-z]*'")
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
            full_key := RegExReplace(input_str, "'([^aoe]h?)'", "'$1[a-z]*'")
            if( StrLen(sim_key)==1 )
                limit_num:=100
        }
    }

    if( full_key=="" ){
        if (input_str~="^''[aoe](''[aoe])*''$") {
            full_key:=input_str
        } else {
            limit_num:=100
        }
    }

    if( !InStr("_12345", SubStr(full_key, 0, 1)) ){
        full_key .= "%"
    }

    full_key := Trim(full_key,"'")
    zero_initials_table:="o"

    if( full_key~="[\.\*\?\|\[\]]" )
    {
        sql_cmd := "jp='" sim_key "' AND key REGEXP '^" full_key "$' "
    }
    else
    {
        sql_cmd := "jp LIKE '" sim_key "'" (full_key?" AND key LIKE '" full_key "'":"") " "
    }

    tooltip_debug[3] .= "`n[" origin_input "]: """ sql_cmd
    tooltip_debug[3] .= "`n" CallStack(4)
    sql_cmd := "SELECT key,value,weight FROM 'pinyin' WHERE " . sql_cmd . " ORDER BY weight DESC" . (limit_num?" LIMIT " limit_num:"")
    if( DB.GetTable(sql_cmd, result_table) )
    {
        ; result_table.Rows = [
        ;   ["wu'hui", "舞会", "30000"]
        ;   ["wu'hui", "误会", "26735"]
        ; ]

        if( result_table.RowCount )
        {
            loop % result_table.RowCount {
                result_table.Rows[A_Index, -1] := origin_input
                result_table.Rows[A_Index, 0] := "pinyin|" A_Index
                result_table.Rows[A_Index, 4] := result_table.Rows[1, 3]
            }
        }
        result_table.Rows[0] := origin_input
        ; result_table.Rows = [
        ;   [0]: "wu'hui"
        ;        ; -1     , 0         , 1
        ;   [1]: ["wu'hui", "pinyin|1", "wu'hui", "舞会", "30000", "30000"]
        ;   [2]: ["wu'hui", "pinyin|2", "wu'hui", "误会", "26735", "30000"]
        ; ]
        tooltip_debug[3] .= """->(" result_table.RowCount ")"
        ; tooltip_debug[3] .= "`n" origin_input "," full_key ": " result_table.RowCount " (" origin_input ")" "`n" sql_cmd "`n" CallStack(1)
        return result_table.Rows
    } else {
        return []
    }
}
