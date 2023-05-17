; Get first letter and tone
;
; e.g.
; "ni0hao0" -> [n_h_]
; "zhong0hua0" -> [z_h_]
; "wo3ai4ni3" -> [w3a4n3]
; "wo0ai0ni0" -> [w_a_n_]
; "s%0wa0l%0b%1" -> [s_w_l_b1]
; "zh%0r%0m%0g%0h%0g%0" -> [z_r_m_g_h_g_]
; "ta0de1" -> [t_d1]
; "z?e0yang0z?i3" -> [z_y_z3]
; "s?u0" -> [s_]
; "wo%0ni" -> [w___n_]
;
PinyinSqlSimpleKey(splitted_input)
{
    key_value := splitted_input
    key_value := StrReplace(key_value, "+0", "__")
    key_value := StrReplace(key_value, "*0", "%_")
    key_value := StrReplace(key_value, "?")
    key_value := StrReplace(key_value, "0", "_")
    key_value := RegExReplace(key_value, "([a-z])[a-z%]+", "$1", occurr_cnt)
    return key_value
}

PinyinSqlFullKey(splitted_input)
{
    key_value := splitted_input
    key_value := StrReplace(key_value, "*", "[a-z1-5]*")
    key_value := StrReplace(key_value, "+", "[a-z]+")
    key_value := RegExReplace(key_value, "([zcs])\?", "$1h^")
    key_value := RegExReplace(key_value, "([n])\?", "$1g^")
    key_value := StrReplace(key_value, "?", ".")
    key_value := StrReplace(key_value, "^", "?")
    key_value := StrReplace(key_value, "0", "_")
    return key_value
}

;*******************************************************************************
;
PinyinSqlGenerateWhereCondition(key_name, key_value, is_full_key:=false)
{
    sql_where_cmd := ""
    if( key_value )
    {
        ; Because use "[15]" in simple key is too slow, we only test it in full key
        if( is_full_key ) {
            key_value := StrReplace(key_value, "1", "[15]")
        } else {
            key_value := StrReplace(key_value, "1", "_")
        }

        if( InStr(key_value, "[") || InStr(key_value, "?") || InStr(key_value, ".") )
        {
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

PinyinSqlGenerateWhereCommand(sim_key, full_key)
{
    Assert(sim_key != "", sim_key "," full_key)
    sql_where_cmd := PinyinSqlGenerateWhereCondition("sim", sim_key)

    if( full_key ) {
        sql_where_cmd .= "AND " PinyinSqlGenerateWhereCondition("key", full_key, true)
    }
    return sql_where_cmd
}

;*******************************************************************************
; Get the reseult from database
; In:
;   % = has vowels
;   a-z = pinyin
;   [012345] = tone
PinyinSqlGetResult(splitted_input, limit_num:=100)
{
    local
    Critical
    begin_tick := A_TickCount

    ; auto_complete := (SubStr(splitted_input, 0, 1) == "*")
    ; splitted_input := RTrim(splitted_input, "*")

    Assert(splitted_input != "", splitted_input)
    Assert(splitted_input != "+0")
    Assert(splitted_input != "*0")

    sql_sim_key     := PinyinSqlSimpleKey(splitted_input)
    sql_full_key    := PinyinSqlFullKey(splitted_input)

    sql_where_cmd := PinyinSqlGenerateWhereCommand(sql_sim_key, sql_full_key)
    sql_full_cmd := "SELECT key,value,weight,comment FROM 'pinyin' WHERE " . sql_where_cmd
    sql_full_cmd .= " ORDER BY weight DESC" . (limit_num?" LIMIT " limit_num:"")

    profile_text := ImeProfilerBegin(15)
    result := []
    pinyin_db := ImeDBGet()
    if( pinyin_db.GetTable(sql_full_cmd, result_table) )
    {
        ; result_table.Rows = [
        ;   [1]: ["lao3shi1", "老师", "26995", ""]
        ;   [2]: ["lao3shi4", "老是", "25921", ""]
        ;   [3]: ["lao3shi2", "老实", "25877", ""]
        ;   ...
        ; ]
        result := result_table.Rows
    }
    ; word length
    auto_complete := true
    if( auto_complete ) {
        loop % result.Length() {
            word_length := StrLen(TranslatorResultGetWord(result[A_Index]))
            TranslatorResultSetWordLength(result[A_Index], word_length)
        }
    } else {
        word_length := StrLen(TranslatorResultGetWord(result[1]))
        loop % result.Length() {
            TranslatorResultSetWordLength(result[A_Index], word_length)
        }
    }

    ImeProfilerEnd(15, profile_text . "`n  - (" A_TickCount - begin_tick ") " . sql_where_cmd)
    ImeProfilerEnd(16, ImeProfilerBegin(16) "`n  - [""" splitted_input """] -> (" result.Length() ")")
    return result
}

;*******************************************************************************
; 
PinyinSqlGetWeight(splitted_input, simple_only := false)
{
    Assert(splitted_input)

    sql_sim_key     := PinyinSqlSimpleKey(splitted_input)
    if( !simple_only ){
        sql_full_key := PinyinSqlFullKey(splitted_input)
    } else {
        sql_full_key := ""
    }

    sql_where_cmd := PinyinSqlGenerateWhereCommand(sql_sim_key, sql_full_key)
    sql_full_cmd := "SELECT weight FROM 'pinyin' WHERE " . sql_where_cmd
    sql_full_cmd .= " ORDER BY weight DESC LIMIT 1"

    result := 0
    pinyin_db := ImeDBGet()
    if( pinyin_db.GetTable(sql_full_cmd, result_table) )
    {
        if( result_table.RowCount > 0 ){
            result := result_table.Rows[1, 1]
        }
    }
    return result
}

;*******************************************************************************
;
PinyinSqlSimpleKeyTest()
{
    test_case := [ "ni0hao0", "zhong0hua0", "wo3ai4ni3", "wo0ai0ni0", "s%0wa0l%0b%1", "zh%0r%0m%0g%0h%0g%0", "ta0de1", "z?e0yang0z?i3", "s?u0" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := PinyinSqlSimpleKey(input_case)
        msg_string .= "`n""" input_case """ -> [" test_result "]"
    }
    MsgBox, % msg_string
}
