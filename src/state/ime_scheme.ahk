ImeSchemeInitialize()
{
    global ime_scheme_normal := 1
    global ime_scheme_simple := 0
    global ime_scheme_double := 0
    global ime_scheme_bopomofo := 0
}

ImeSchemeIsPinyinNormal()
{
    global ime_scheme_normal
    return ime_scheme_normal
}

ImeSchemeIsPinyinSimple()
{
    global ime_scheme_simple
    return ime_scheme_simple
}

ImeSchemeIsPinyinDouble()
{
    global ime_scheme_double
    return ime_scheme_double
}

ImeSchemeIsPinyinBopomofo()
{
    global ime_scheme_bopomofo
    return ime_scheme_bopomofo
}

;*******************************************************************************
;
ImeSchemeSimpleToggle()
{
    global ime_scheme_simple
    ime_scheme_simple := !ime_scheme_simple
}

ImeSchemeSimpleSet(force)
{
    global ime_scheme_simple
    ime_scheme_simple := force
}

;*******************************************************************************
;
ImeSchemeDoubleSet(force)
{
    global ime_scheme_double
    ime_scheme_double := force
}

ImeSchemeBopomofoSet(force)
{
    global ime_scheme_bopomofo
    ime_scheme_bopomofo := force
}

