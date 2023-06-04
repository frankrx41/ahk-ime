ImeSchemeInitialize()
{
    global ime_mode_scheme
    ime_mode_scheme := "normal"     ; "double", "simple"
}

ImeSchemeIsPinyinNormal()
{
    global ime_mode_scheme
    return ime_mode_scheme == "normal"
}

ImeSchemeIsPinyinSimple()
{
    global ime_mode_scheme
    return ime_mode_scheme == "simple"
}

ImeSchemeIsPinyinDouble()
{
    global ime_mode_scheme
    return ime_mode_scheme == "double"
}

;*******************************************************************************
;
ImeSimpleSpellToggle()
{
    global ime_mode_scheme
    if( ImeSchemeIsPinyinSimple() ) {
        ime_mode_scheme := "normal"
    } else {
        ime_mode_scheme := "simple"
    }
}

ImeSimpleSpellSetForce(force)
{
    global ime_mode_scheme
    if( force ) {
        ime_mode_scheme := "simple"
    } else {
        ime_mode_scheme := "normal"
    }
}

ImeSimpleSpellIsForce()
{
    global ime_mode_scheme
    return ime_mode_scheme == "simple"
}
