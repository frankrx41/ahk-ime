; ni'hao' -> n_h_
; zhong'hua -> z_h_
; wo3ai4ni3 -> w3a4n3
; wo3ai4ni% -> w3a4n% or w3a4n_
; s?u -> s_
PinyinSqlSimpleKey(split_input, auto_comple:=false)
{
    key_value := split_input
    key_value := StrReplace(key_value, "?")
    key_value := StrReplace(key_value, "'", "_")
    key_value := RegExReplace(key_value, "([a-z])[a-z%]+", "$1", occurr_cnt)
    if( auto_comple ){
        key_value .= "%"
    }
    else if( !InStr("_12345", SubStr(key_value, 0, 1)) ){
        key_value .= "_"
    }
    ; key_value := StrReplace(key_value, "1", "_")
    return key_value
}

PinyinSqlFullKey(split_input, auto_comple:=false)
{
    key_value := split_input
    key_value := StrReplace(key_value, "?", "h?")
    key_value := StrReplace(key_value, "'", "_")
    last_char := SubStr(key_value, 0, 1)

    if( !InStr("_%12345", last_char) ){
        key_value .= "%_"
    }
    return key_value
}

PinyinSqlWhereKeyCommand(key_name, key_value, repalce_tone_1_5:=false)
{
    sql_cmd := ""
    if( key_value )
    {
        if( repalce_tone_1_5 ) {
            key_value := StrReplace(key_value, "1", "[15]")
        } else {
            key_value := StrReplace(key_value, "1", "_")
        }
        ; key_value := StrReplace(key_value, "_", ".")
        if( InStr(key_value, "[") || InStr(key_value, "?") || InStr(key_value, ".") )
        {
            key_value := StrReplace(key_value, "_", "[1-5]")
            key_value := StrReplace(key_value, "%", "[a-z]*")
            sql_cmd := " REGEXP '^" key_value "$' "
        }
        else
        if( InStr(key_value, "_") || InStr(key_value, "%") )
        {
            sql_cmd := " LIKE '" key_value "' "
        }
        else
        {
            sql_cmd := " = '" key_value "' "
        }
        sql_cmd := key_name . sql_cmd
    }
    return sql_cmd
}

PinyinSqlWhereCommand(sim_key, full_key)
{
    Assert(sim_key,,,true)
    sql_cmd := PinyinSqlWhereKeyCommand("sim", sim_key)

    if( full_key )
    {
        sql_cmd .= "AND " PinyinSqlWhereKeyCommand("key", full_key, true)
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
PinyinSqlGetResult(DB, split_input, auto_comple:=false, limit_num:=100)
{
    local
    Critical
    begin_tick := A_TickCount
    ImeProfilerBegin(15)
    ; Get first char
    sql_sim_key     := PinyinSqlSimpleKey(split_input, auto_comple)
    sql_full_key    := PinyinSqlFullKey(split_input, auto_comple)
    if( StrLen(sql_full_key) != 2 && StrReplace(sql_full_key, "%") == sql_sim_key ){
        sql_full_key := ""
    }

    sql_cmd_where := PinyinSqlWhereCommand(sql_sim_key, sql_full_key)
    ImeProfilerEnd(15)

    sql_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_cmd_where
    sql_cmd .= " ORDER BY weight DESC" . (limit_num?" LIMIT " limit_num:"")

    ImeProfilerBegin(16)
    result := []
    if( DB.GetTable(sql_cmd, result_table) )
    {
        length := SplitWordGetWordCount(split_input)
        loop % result_table.RowCount {
            result_table.Rows[A_Index, 5] := length
        }
        result_table.Rows[0] := split_input
        ; result_table.Rows = [
        ;   [0]: "wu'hui'"
        ;   [1]: ["wu3hui4", "舞会", "30000", "", 2]
        ;   [2]: ["wu4hui4", "误会", "26735", "", 2]
        ; ]
        result := result_table.Rows
    }

    ; "`n" origin_input "," full_key_1 ": " result_table.RowCount " (" origin_input ")" "`n" sql_cmd "`n" CallStack(1)
    ImeProfilerEnd(16, "`n  - [" split_input "] -> {" result.Length() "}")
    ImeProfilerSetDebugInfo(15, "`n  - (" A_TickCount - begin_tick ") " . sql_cmd_where)
    return result
}
