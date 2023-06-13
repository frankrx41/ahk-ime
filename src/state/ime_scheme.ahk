ImeSchemeInitialize()
{
    global ime_scheme_simple := 0       ; 全简拼
    global ime_scheme_double := 0       ; 双拼
    global ime_scheme_bopomofo := 0     ; 注音
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
ImeSchemeSimpleSet(force)
{
    global ime_scheme_simple
    ime_scheme_simple := force
}

;*******************************************************************************
;
ImeSchemeSimpleToggle()
{
    global ime_scheme_simple
    ime_scheme_simple := !ime_scheme_simple
}

ImeSchemeDoubleToggle()
{
    global ime_scheme_double
    ime_scheme_double := !ime_scheme_double
}

ImeSchemeBopomofoToggle()
{
    global ime_scheme_bopomofo
    ime_scheme_bopomofo := !ime_scheme_bopomofo
}
