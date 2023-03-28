EscapeCharsIsMark(word)
{
    return InStr("{}", word)
}

EscapeCharsGetMark(get_right, is_regex := false)
{
    mark := ""
    mark .= is_regex ? "\" : ""
    mark .= (get_right == 0) ? "{" : "}"
    return mark
}

EscapeCharsGetRegex()
{
    return EscapeCharsGetMark(0, 1) . ".*?" . EscapeCharsGetMark(1, 1)
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

EscapeCharsGetContent(word)
{
    word := RegExReplace(word, EscapeCharsGetMark(0, 1) . "(.*?)" . EscapeCharsGetMark(1, 1), "$1")
    return word
}
