SplittedInputGetWordCount(splitted_input)
{
    ; 包含 word + tone + word + ... 格式
    RegExReplace(splitted_input, "([012345])", "", count_use)
    return count_use
}

SplittedInputRemoveLastWord(splitted_input, repeat_count:=1)
{
    loop, % repeat_count
    {
        splitted_input := RegExReplace(splitted_input, "([^012345]+[012345])$")
    }
    return splitted_input
}

; Convert a splited string to a simple spell splited string
;
; e.g.
; "wo3ai4ni3" -> [w%0o%3a%0i%4n%0i%3]
; "wo0ai0ni0" -> [w%0o%0a%0i%0n%0i%0]
; "s%0wa0l%0b%1" -> [s%0w%0a%0l%0b%1]
; "zh%0r%0m%0g%0h%0g%0" -> [z%0h%0r%0m%0g%0h%0g%0]
; "ta0de1" -> [t%0a%0d%0e%1]
; "z?e0yang0z?i3" -> [z%0e%0y%0a%0n%0g%0z%0i%3]
;
; See `SplittedInputConvertToSimpleSpellTest`
SplittedInputConvertToSimpleSpell(input_string)
{
    input_string := StrReplace(input_string, "?")
    input_string := RegExReplace(input_string, "([a-z])(?=[^%012345])", "$10")
    input_string := RegExReplace(input_string, "([^%])([012345])", "$1%$2")
    return input_string
}

SplittedInputConvertToSimpleSpellTest()
{
    test_case := [ "wo3ai4ni3", "wo0ai0ni0", "s%0wa0l%0b%1", "zh%0r%0m%0g%0h%0g%0", "ta0de1", "z?e0yang0z?i3" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := SplittedInputConvertToSimpleSpell(input_case)
        msg_string .= "`n""" input_case """ -> [" test_result "]"
    }
    MsgBox, % msg_string
}
