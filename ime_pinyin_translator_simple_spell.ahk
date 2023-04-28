;*******************************************************************************
; Simple Spell
;
;*******************************************************************************
; Convert a splited string to a simple spell splited string
;
; e.g.
; "wo3ai4ni3" -> [w%0o%3a%0i%4n%0i%3,6]
; "wo0ai0ni0" -> [w%0o%0a%0i%0n%0i%0,6]
; "s%0wa0l%0b%1" -> [s%0w%0a%0l%0b%1,5]
; "zh%0r%0m%0g%0h%0g%0" -> [z%0h%0r%0m%0g%0h%0g%0,7]
; "ta0de1" -> [t%0a%0d%0e%1,4]
; "z?e0yang0z?i3" -> [z%0e%0y%0a%0n%0g%0z%0i%3,8]
;
; See `SplittedInputConvertToSimpleSpellTest`
SplittedInputConvertToSimpleSpell(input_string, ByRef word_count)
{
    input_string := StrReplace(input_string, "?")
    input_string := RegExReplace(input_string, "([a-z])(?=[^%012345])", "$10")
    input_string := RegExReplace(input_string, "([^%])([012345])", "$1%$2")
    StrReplace(input_string, "%", "", word_count)
    return input_string
}

;*******************************************************************************
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

    if( simple_spell_list.HasKey(RegExReplace(splitted_string, "%[012345]")) )
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

PinyinTranslatorInsertSimpleSpell(ByRef translate_result, splitter_result, auto_complete)
{
    local

    if( splitter_result.Length() == 1 && !auto_complete){
        return
    }

    splitted_input := SplitterResultConvertToString(splitter_result, 1)
    splitted_string := SplittedInputConvertToSimpleSpell(splitted_input, length_count)
    if(!splitted_string){
        return
    }

    profile_text := ImeProfilerBegin(22)
    if( SeparateStringShouldProcess(splitted_string, splitted_input) )
    {
        if( auto_complete ){
            splitted_string .= "*"
        }
        TranslatorHistoryUpdateKey(splitted_string, length_count)
        TranslatorHistoryInsertResultAt(translate_result, splitted_string, 1)
        profile_text := "[""" SplitterResultConvertToString(splitter_result, 1) """] -> [""" splitted_string """," length_count "]"
    }
    ImeProfilerEnd(22, profile_text)
    return
}

;*******************************************************************************
;
SplittedInputConvertToSimpleSpellTest()
{
    test_case := [ "wo3ai4ni3", "wo0ai0ni0", "s%0wa0l%0b%1", "zh%0r%0m%0g%0h%0g%0", "ta0de1", "z?e0yang0z?i3" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := SplittedInputConvertToSimpleSpell(input_case, word_count)
        msg_string .= "`n""" input_case """ -> [" test_result "," word_count "]"
    }
    MsgBox, % msg_string
}
