ImeSimpleSpellInitialize()
{
    global ime_is_force_simple_spell
    ime_is_force_simple_spell   := false
    
}

;*******************************************************************************
; Simple spell
ImeSimpleSpellIsForce()
{
    global ime_is_force_simple_spell
    return ime_is_force_simple_spell
}

ImeSimpleSpellToggle()
{
    global ime_is_force_simple_spell
    ime_is_force_simple_spell := !ime_is_force_simple_spell
}

ImeSimpleSpellSetForce(force)
{
    global ime_is_force_simple_spell
    ime_is_force_simple_spell := force
}
