;*******************************************************************************
; 超级简拼
;
; "wo3xi3huan'ni'" -> "w%'o%3x%'i%3h%'u%'a%'n%'n%'i%'"
; "wo3ai4ni'" -> "w%'o%3a%'i%4n%'i%'"
; "wo'xi3huan1ni3" -> "w%'o%'x%'i%3h%'u%'a%'n%1n%'i%3"
SplitWordGetSimpleSpell(input_string)
{
    input_string := RegExReplace(input_string, "([a-z])(?=[^%'12345])", "$1'")
    input_string := RegExReplace(input_string, "([^%])(['12345])", "$1%$2")
    return input_string
}

; Not include "i" "u" "v"
SeparateStringHasSound(separate_string)
{
    return !RegExMatch(separate_string, "[iuv]%")
}

SeparateStringShouldProcess(separate_string, input_split)
{
    local
    static simple_spell_list := { "yeb":1, "mla": 1 }
    if( PinyinSqlSimpleKey(separate_string) == PinyinSqlSimpleKey(input_split) )
    {
        return false
    }
    if( !SeparateStringHasSound(separate_string) )
    {
        return false
    }

    if( simple_spell_list.HasKey(RegExReplace(separate_string, "%['12345]")) )
    {
        return true
    }
    str_len := StrLen(separate_string)/3
    if( str_len < 4 || str_len > 8 )
    {
        return false
    }
    return true
}

PinyinResultInsertSimpleSpell(ByRef DB, ByRef search_result, input_split)
{
    local
    global history_field_array
    global tooltip_debug

    if( SplitWordGetWordCount(input_split) > 1 )
    {
        separate_string := SplitWordGetSimpleSpell(input_split)
        if( SeparateStringShouldProcess(separate_string, input_split) )
        {
            PinyinHistoryUpdateKey(DB, separate_string, true)
            PinyinResultInsertAtHistory(search_result, separate_string, 1)
            tooltip_debug[8] .= """" separate_string """->(" PinyinHistoryGetResultLength(separate_string) ")"
        }
    }
    return
}
