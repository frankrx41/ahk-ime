SplitWordGetWordCount(word)
{
    word := EscapeCharsRemove(word, count_unsed)
    ; 包含 word + tone + word + ... 格式
    RegExReplace(word, "(['12345])", "", count_use)
    total_count := count_unsed + count_use
    return total_count
}

SplitWordTrimMaxCount(word, max)
{
    ; TODO: Escape char
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

SplitWordRemoveFirstWord(word)
{
    if( EscapeCharsIsMark(SubStr(word, 1, 1)) ){
        return EscapeCharsRemoveFirst(word)
    }
    else{
        ; "kai'xin'a'" -> "xin'a'"
        return RegExReplace(word, "^[^'12345]+['12345]?")
    }
}

SplitWordRemoveLastWord(word)
{
    if( EscapeCharsIsMark(SubStr(word, 0, 1)) ){
        return EscapeCharsRemoveLast(word)
    }
    else{
        ; "kai'xin'a'" -> "kai'xin'"
        ; "wo'" -> ""
        return RegExReplace(word, "([^'12345]+['12345])$")
    }
}

SplitWordGetPrevWords(word)
{
    if( EscapeCharsIsMark(SubStr(word, 1, 1)) ){
        return EscapeCharsGetFirst(word)
    }
    else
    {
        return RegExReplace(word, "[" . EscapeCharsGetLeftMark()  . "].*$")
    }
}
