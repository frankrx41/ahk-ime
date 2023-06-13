PinyinCovertQuestionMarkToRegexFormat(pinyin)
{
    pinyin := RegExReplace(pinyin, "([zcs])\?", "$1h^")   ; ^ temporary mark "?"
    pinyin := RegExReplace(pinyin, "n\?", "ng^")          ; wan? = wan + wang
    pinyin := RegExReplace(pinyin, "i\?n", "i.^n")        ; xi?n = xin + xian
    pinyin := StrReplace(pinyin, "?", ".")
    pinyin := StrReplace(pinyin, "^", "?")
    return pinyin
}

SoundSplit(pinyin)
{
    array := []
    position := 0
    loop, Parse, pinyin, % "012345"
    {
        ; Calculate the position of the delimiter at the end of this field.
        position += StrLen(A_LoopField) + 1
        ; Retrieve the delimiter found by the parsing loop.
        delimiter := SubStr(pinyin, position, 1)
        if( A_LoopField ) {
            array.Push(A_LoopField)
            array.Push(delimiter)
        }
    }
    return array
}

; Check wiki\design.md#Input
; wo0de0 - wo3de5
IsPinyinSoundLike(input_pinyin, full_pinyin)
{
    full_pinyin_list    := SoundSplit(full_pinyin)
    input_pinyin_list   := SoundSplit(input_pinyin)

    loop_count := full_pinyin_list.Length() / 2
    ; Assert(input_pinyin_list.Length() == full_pinyin_list.Length(), input_pinyin "," full_pinyin)
    if( input_pinyin_list.Length() != full_pinyin_list.Length() )
    {
        return false
    }

    loop, % loop_count
    {
        index := 1 + (A_Index-1) * 2

        test_full_pinyin    := full_pinyin_list[index]
        test_input_pinyin   := input_pinyin_list[index]

        test_input_pinyin   := PinyinCovertQuestionMarkToRegexFormat(test_input_pinyin)
        test_input_pinyin   := StrReplace(test_input_pinyin, "%", ".*")
        test_input_pinyin   := "^" test_input_pinyin "$"

        if( !RegExMatch(test_full_pinyin, test_input_pinyin) )
        {
            return false
        }

        full_tone   := full_pinyin_list[index+1]
        input_tone  := input_pinyin_list[index+1]
        if( full_tone == input_tone || input_tone == "0" )
        {
            continue
        }
        if( full_tone == "5" && input_tone == "1" )
        {
            continue
        }
        return false
    }
    return true
}
