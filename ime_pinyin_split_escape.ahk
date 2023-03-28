EscapeCharsIsMark(word)
{
    return InStr("{}", word)
}

EscapeCharsGetLeftMark()
{
    return "{"
}

EscapeCharsGetRightMark()
{
    return "}"
}

EscapeCharsGetRegex()
{
    return "\" . EscapeCharsGetLeftMark() . ".*?" . "\" . EscapeCharsGetRightMark()
}

EscapeCharsRemove(word, ByRef count)
{
    word := RegExReplace(word, EscapeCharsGetRegex(), "", count)
    return word
}

EscapeCharsRemoveFirst(word)
{
    return RegExReplace(word, "^" EscapeCharsGetRegex() "(.*)$", "$1")
}

EscapeCharsRemoveLast(word)
{
    return RegExReplace(word, "^(.*)" EscapeCharsGetRegex() "$", "$1")
}

EscapeCharsGetFirst(word)
{
    return RegExReplace(word, "^(" EscapeCharsGetRegex() ").*$", "$1")
}
