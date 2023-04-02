;*******************************************************************************
; 超级简拼
;
; "wo3xi3huan'ni'" -> "w%'o%3x%'i%3h%'u%'a%'n%'n%'i%'"
; "wo3ai4ni'" -> "w%'o%3a%'i%4n%'i%'"
; "wo'xi3huan1ni3" -> "w%'o%'x%'i%3h%'u%'a%'n%1n%'i%3"
SplittedInputGetSimpleSpell(input_string)
{
    input_string := StrReplace(input_string, "?")
    input_string := RegExReplace(input_string, "([a-z])(?=[^%'12345])", "$1'")
    input_string := RegExReplace(input_string, "([^%])(['12345])", "$1%$2")
    return input_string
}

; Not include "i" "u" "v"
SeparateStringHasSound(splitted_string)
{
    return !RegExMatch(splitted_string, "[iuv]%")
}

SeparateStringShouldProcess(splitted_string, splitted_input)
{
    local
    static simple_spell_list := { "yeb":1, "mla": 1 }
    if( PinyinSqlSimpleKey(splitted_string) == PinyinSqlSimpleKey(splitted_input) )
    {
        return false
    }
    if( !SeparateStringHasSound(splitted_string) )
    {
        return false
    }

    if( simple_spell_list.HasKey(RegExReplace(splitted_string, "%['12345]")) )
    {
        return true
    }
    str_len := StrLen(splitted_string)/3
    if( str_len < 4 || str_len > 8 )
    {
        return false
    }
    return true
}

PinyinTranslateInsertSimpleSpell(ByRef search_result, splitted_input)
{
    local
    global history_field_array
    ImeProfilerBegin(22)
    debug_string := ""
    if( SplittedInputGetWordCount(splitted_input) > 1 )
    {
        splitted_string := SplittedInputGetSimpleSpell(splitted_input)
        if( SeparateStringShouldProcess(splitted_string, splitted_input) )
        {
            PinyinHistoryUpdateKey(splitted_string, true)
            PinyinResultInsertAtHistory(search_result, splitted_string, 1)
            debug_string := """" splitted_string """->(" PinyinHistoryGetResultLength(splitted_string) ")"
        }
    }
    ImeProfilerEnd(22, debug_string)
    return
}
