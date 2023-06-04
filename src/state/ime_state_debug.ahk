ImeDebugInitialize()
{
    global ime_debug_switch
    ime_debug_switch            := 0            ; 0 hide 1 show tick only 2 show full
}

;*******************************************************************************
; Debug
ImeDebugGet()
{
    global ime_debug_switch
    return ime_debug_switch
}

ImeDebugToggle()
{
    global ime_debug_switch
    ime_debug_switch += 1
    if( ime_debug_switch >= 3 ) {
        ime_debug_switch := 0
    }
}
