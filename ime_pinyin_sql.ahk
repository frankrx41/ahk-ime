; ni'hao' -> n_h_
; zhong'hua -> z_h_
; wo3ai4ni3 -> w3a4n3
; wo3ai4ni% -> w3a4n% or w3a4n_
; s?u -> s_
PinyinSqlSimpleKey(splitted_input, auto_comple:=false)
{
    key_value := splitted_input
    key_value := StrReplace(key_value, "?")
    key_value := StrReplace(key_value, "'", "_")
    key_value := RegExReplace(key_value, "([a-z])[a-z%]+", "$1", occurr_cnt)
    if( auto_comple ){
        key_value .= "%%"
    }
    return key_value
}

PinyinSqlFullKey(splitted_input, auto_comple:=false)
{
    key_value := splitted_input
    key_value := StrReplace(key_value, "?", "h?")
    key_value := StrReplace(key_value, "'", "_")
    last_char := SubStr(key_value, 0, 1)
    if( auto_comple ){
        key_value .= "%%"
    }
    return key_value
}

PinyinSqlWhereKeyCommand(key_name, key_value, repalce_tone_1_5:=false)
{
    sql_where_cmd := ""
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
            key_value := RegexReplace(key_value, "%%$", "[a-z1-5]*")
            key_value := StrReplace(key_value, "_", "[1-5]")
            key_value := StrReplace(key_value, "%", "[a-z]*")
            sql_where_cmd := " REGEXP '^" key_value "$' "
        }
        else
        if( InStr(key_value, "_") || InStr(key_value, "%") )
        {
            sql_where_cmd := " LIKE '" key_value "' "
        }
        else
        {
            sql_where_cmd := " = '" key_value "' "
        }
        sql_where_cmd := key_name . sql_where_cmd
    }
    return sql_where_cmd
}

PinyinSqlWhereCommand(sim_key, full_key)
{
    Assert(sim_key,sim_key,true)
    sql_where_cmd := PinyinSqlWhereKeyCommand("sim", sim_key)

    if( full_key ) {
        sql_where_cmd .= "AND " PinyinSqlWhereKeyCommand("key", full_key, true)
    }
    return sql_where_cmd
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
PinyinSqlGetResult(splitted_input, auto_comple:=false, limit_num:=100)
{
    local
    Critical
    begin_tick := A_TickCount

    sql_sim_key     := PinyinSqlSimpleKey(splitted_input, auto_comple)
    sql_full_key    := PinyinSqlFullKey(splitted_input, auto_comple)

    sql_where_cmd := PinyinSqlWhereCommand(sql_sim_key, sql_full_key)
    sql_full_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_where_cmd
    sql_full_cmd .= " ORDER BY weight DESC" . (limit_num?" LIMIT " limit_num:"")

    ImeProfilerBegin(15)
    result := []
    pinyin_db := ImeDBGet()
    if( pinyin_db.GetTable(sql_full_cmd, result_table) )
    {
        length := SplittedInputGetWordCount(splitted_input)
        loop % result_table.RowCount {
            result_table.Rows[A_Index, 5] := length
        }
        result_table.Rows[0] := splitted_input
        ; result_table.Rows = [
        ;   [0]: "wu'hui'"
        ;   [1]: ["wu3hui4", "舞会", "30000", "", 2]
        ;   [2]: ["wu4hui4", "误会", "26735", "", 2]
        ; ]
        result := result_table.Rows
    }
    ImeProfilerEnd(15, "`n  - (" A_TickCount - begin_tick ") " . sql_where_cmd)

    ImeProfilerBegin(16)
    ImeProfilerEnd(16, "`n  - [" splitted_input "] -> {" result.Length() "}")
    return result
}
