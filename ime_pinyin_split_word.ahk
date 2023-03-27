SplitWordGetWordCount(word)
{
    ; 包含 word + tone + word + ... 格式
    RegExReplace(word, "(['12345])", "", count)
    return count
}

SplitWordTrimMaxCount(word, max)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^(([^'12345]+['12345]?){0," max "}).*$", "$1")
}

SplitWordRemoveFirstWord(word)
{
    ; "kai'xin'a'" -> "xin'a'"
    return RegExReplace(word, "^[^'12345]+['12345]?")
}

SplitWordRemoveLastWord(word)
{
    ; "kai'xin'a'" -> "kai'xin'"
    return RegExReplace(word, "(['12345])([^'12345]+['12345]?)$", "$1")
}
