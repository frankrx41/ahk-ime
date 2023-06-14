ImeDebugLevelInitialize()
{
    global ime_debug_level := 0     ; 0 hide 1 show tick only 2 show full
}

;*******************************************************************************
; Debug
ImeDebugLevelGet()
{
    global ime_debug_level
    return ime_debug_level
}

ImeDebugLevelToggle()
{
    global ime_debug_level
    ime_debug_level += 1
    if( ime_debug_level >= 3 ) {
        ime_debug_level := 0
    }
}
