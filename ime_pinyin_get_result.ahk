; abc_def -> a_f_
; zhong_hua -> z_h_
GetSimpleKey(input_str)
{
    sim_key := Trim(RegExReplace(input_str, "([a-z])[a-z%]+", "$1"), "'")
    if( !InStr("_12345", SubStr(sim_key, 0, 1)) ){
        sim_key .= "_"
    }
    return sim_key
}

GetSimpleKeyLength(sim_key)
{
    ; Replace all digits in the string with an empty string and store the length difference
    length := StrLen(str) - StrLen(RegExReplace(str, "[\d_]"))
    return length
}

GetFullKey(input_str, sim_key)
{
    full_key := input_str
    last_char := SubStr(full_key, 0, 1)
    if( last_char == "%" ){
        full_key .= "_"
    }
    else
    if( !InStr("%_12345", last_char) ){
        full_key .= "%_"
    }

    if( StrReplace(full_key, "%") == sim_key ){
        full_key := ""
    }
    return full_key
}

StrReplaceLast1To5(input_str)
{
    pos := InStr(input_str, "1",,0,1)
    if( pos != 0 ){
        new_str := SubStr(input_str, 1, pos-1) "5" SubStr(input_str, pos+1)
        return new_str
    }else{
        return input_str
    }
}

GetSqlCommand(sim_key, full_key)
{
    if( full_key~="[\.\*\?\|\[\]]" )
    {
        sql_cmd := "sim LIKE '" sim_key "' AND key REGEXP '^" full_key "$' "
    }
    else
    {
        sql_cmd := "sim LIKE '" sim_key "'" (full_key ? " AND key LIKE '" full_key "'" : "") " "
    }
    return sql_cmd
}

; Get the reseult from database
; Input string origin_input must not content "|"
; Please spilt raw input by space then use this to get result
PinyinSqlGetResult(DB, origin_input, limit_num:=100)
{
    local
    Critical
    global tooltip_debug

    origin_input := LTrim(origin_input, "'")
    Assert(!InStr(origin_input, "|"))

    input_str   := origin_input
    input_str   := StrReplace(input_str, "'", "_")

    ; Get first char
    sim_key_1   := GetSimpleKey(input_str)
    full_key_1  := GetFullKey(input_str, sim_key_1)
    sql_cmd_1   := GetSqlCommand(sim_key_1, full_key_1)
    tooltip_debug[3] .= "`n[" origin_input "]: """ sql_cmd_1
    ; tooltip_debug[3] .= "`n" CallStack(4)

    ; tone 1 -> 5
    full_key_5  := StrReplaceLast1To5(full_key_1)
    if( full_key_5 != full_key_1 ){
        sim_key_5 := StrReplaceLast1To5(sim_key_1)
        sql_cmd_5 := GetSqlCommand(sim_key_5, full_key_5)
    } else {
        sql_cmd_5 := ""
    }

    sql_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_cmd_1
    if( sql_cmd_5 ){
        sql_cmd .= "UNION "
        sql_cmd .= "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_cmd_5
    }
    sql_cmd .= " ORDER BY weight DESC" . (limit_num?" LIMIT " limit_num:"")

    if( DB.GetTable(sql_cmd, result_table) )
    {
        ; result_table.Rows = [
        ;   ["wu'hui", "舞会", "30000", "备注"]
        ;   ["wu'hui", "误会", "26735", ""]
        ; ]

        if( result_table.RowCount )
        {
            loop % result_table.RowCount {
                ; result_table.Rows[A_Index, -1] := origin_input
                ; result_table.Rows[A_Index, 0] := "pinyin|" A_Index
                ; result_table.Rows[A_Index, 4] := result_table.Rows[1, 3]
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
        ; tooltip_debug[3] .= "`n" origin_input "," full_key_1 ": " result_table.RowCount " (" origin_input ")" "`n" sql_cmd "`n" CallStack(1)
        return result_table.Rows
    } else {
        return []
    }
}
