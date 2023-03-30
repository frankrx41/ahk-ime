SplitWordGetWordCount(split_input)
{
    split_input := EscapeCharsRemove(split_input, count_unsed)
    ; 包含 word + tone + word + ... 格式
    RegExReplace(split_input, "(['12345])", "", count_use)
    total_count := count_unsed + count_use
    return total_count
}

SplitWordTrimMaxCount(split_input, max)
{
    ; TODO: Check scape char
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(split_input, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

SplitWordGetFirstWord(split_input)
{
    ; TODO: Check scape char
    return RegExReplace(split_input, "^([a-z]+[12345' ]).*", "$1")
}

SplitWordRemoveFirstWord(split_input)
{
    if( EscapeCharsIsMark(SubStr(split_input, 1, 1)) ){
        return EscapeCharsRemoveFirst(split_input)
    }
    else{
        ; "kai'xin'a'" -> "xin'a'"
        return RegExReplace(split_input, "^[^'12345]+['12345]?")
    }
}

SplitWordRemoveLastWord(split_input)
{
    if( EscapeCharsIsMark(SubStr(split_input, 0, 1)) ){
        return EscapeCharsRemoveLast(split_input)
    }
    else{
        ; "kai'xin'a'" -> "kai'xin'"
        ; "wo'" -> ""
        return RegExReplace(split_input, "([^'12345]+['12345])$")
    }
}

SplitWordGetPrevWords(split_input)
{
    if( EscapeCharsIsMark(SubStr(split_input, 1, 1)) ){
        return EscapeCharsGetFirst(split_input)
    }
    else
    {
        return RegExReplace(split_input, "[" . EscapeCharsGetMark(0, 0)  . "].*$")
    }
}
