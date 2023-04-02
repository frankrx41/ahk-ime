SplittedInputGetWordCount(splitted_input)
{
    splitted_input := EscapeCharsRemove(splitted_input, count_unsed)
    ; 包含 word + tone + word + ... 格式
    RegExReplace(splitted_input, "(['12345])", "", count_use)
    total_count := count_unsed + count_use
    return total_count
}

SplittedInputTrimMaxCount(splitted_input, max)
{
    ; TODO: Check scape char
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(splitted_input, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

SplittedInputGetFirstWord(splitted_input)
{
    ; TODO: Check scape char
    return RegExReplace(splitted_input, "^([a-z]+[12345' ]).*", "$1")
}

SplittedInputRemoveFirstWord(splitted_input, repeat_count:=1)
{
    loop, % repeat_count
    {
        if( EscapeCharsIsMark(SubStr(splitted_input, 1, 1)) ){
            splitted_input := EscapeCharsRemoveFirst(splitted_input)
        }
        else{
            ; "kai'xin'a'" -> "xin'a'"
            splitted_input := RegExReplace(splitted_input, "^[^'12345]+['12345]?")
        }
    }
    return splitted_input
}

SplittedInputRemoveLastWord(splitted_input, repeat_count:=1)
{
    loop, % repeat_count
    {
        if( EscapeCharsIsMark(SubStr(splitted_input, 0, 1)) ){
            splitted_input := EscapeCharsRemoveLast(splitted_input)
        }
        else{
            ; "kai'xin'a'" -> "kai'xin'"
            ; "wo'" -> ""
            splitted_input := RegExReplace(splitted_input, "([^'12345]+['12345])$")
        }
    }
    return splitted_input
}

SplittedInputGetPrevWords(splitted_input)
{
    if( EscapeCharsIsMark(SubStr(splitted_input, 1, 1)) ){
        return EscapeCharsGetFirst(splitted_input)
    }
    else
    {
        return RegExReplace(splitted_input, "[" . EscapeCharsGetMark(0, 0)  . "].*$")
    }
}
