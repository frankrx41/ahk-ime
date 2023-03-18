; ni'hao' -> n_h_
; zhong'hua -> z_h_
; wo3ai4ni3 -> w3a4n3
; wo3de1 -> w3d[15]
GetSqlSimpleKey(input_str)
{
    key_value := input_str
    last_char := SubStr(key_value, 0, 1)
    key_value := StrReplace(key_value, "'", "_")
    key_value := RegExReplace(key_value, "([a-z])[a-z%]+", "$1", occurr_cnt)
    if( last_char == "%" ){
        ; simple spell mode
        if( occurr_cnt >= 4 ){
            key_value .= "%"
        } else {
            key_value .= "_"
        }
    }
    else if( !InStr("_12345", SubStr(key_value, 0, 1)) ){
        key_value .= "_"
    }
    ; key_value := StrReplace(key_value, "1", "_")
    return key_value
}

GetFullKey(input_str, sim_key)
{
    key_value := input_str
    key_value := StrReplace(key_value, "'", "_")
    last_char := SubStr(key_value, 0, 1)

    if( !InStr("_%12345", last_char) ){
        key_value .= "%_"
    }

    if( StrReplace(key_value, "%") == sim_key ){
        key_value := ""
    }
    return key_value
}

StrReplaceLast1To5(input_str)
{
    tone_pos := InStr(input_str, "1",,0,1)
    if( tone_pos != 0 ){
        new_str := SubStr(input_str, 1, tone_pos-1) "5" SubStr(input_str, tone_pos+1)
        return new_str
    }else{
        return ""
    }
}

GetSqlWhereKeyCommand(key_name, key_value, repalce15:=false)
{
    sql_cmd := ""
    if( key_value )
    {
        if( InStr(key_value, "_") || InStr(key_value, "%") )
        {
            sql_cmd := " LIKE '" key_value "' "
        }
        else
        {
            sql_cmd := " = '" key_value "' "
        }
        sql_cmd := key_name . sql_cmd

        if( repalce15 )
        {
            new_value := StrReplaceLast1To5(key_value)
            if( new_value ){
                sql_cmd := "( " sql_cmd "OR " . GetSqlWhereKeyCommand(key_name, new_value) ") "
            }
        }
    }
    return sql_cmd
}

GetSqlWhereCommand(sim_key, full_key)
{
    Assert(sim_key)
    sql_cmd := GetSqlWhereKeyCommand("sim", sim_key, true)

    if( full_key )
    {
        sql_cmd .= "AND " GetSqlWhereKeyCommand("key", full_key, true)
    } 
    return sql_cmd
}

; Get the reseult from database
; Input string origin_input must not content "|"
; Please spilt raw input by space then use this to get result
; % = has vowels
; ['12345] = split word
; if last char is %, mean need continue input
; e.g.
; ki -> k%'i'
; wo3ai4ni3 -> wo3ai4ni3
; kannid -> kan'ni'd%
; kannide -> kan'ni'de'
PinyinSqlGetResult(DB, input_str, limit_num:=100)
{
    local
    Critical
    global tooltip_debug

    ; input_str := LTrim(input_str, "'")
    Assert(!InStr(input_str, "|"))
    ; Assert(SubStr(input_str, 0, 1) != "'")

    ; Get first char
    sql_sim_key     := GetSqlSimpleKey(input_str)
    sql_full_key    := GetFullKey(input_str, sql_sim_key)
    sql_cmd         := GetSqlWhereCommand(sql_sim_key, sql_full_key)
    tooltip_debug[3] .= "`n[" input_str "]: """ sql_cmd
    ; tooltip_debug[3] .= "`n" CallStack(4)

    sql_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_cmd
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
        result_table.Rows[0] := input_str
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
