#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include, ime_assert.ahk
#Include, ime_func.ahk

GetSimpleSpellString(input_string)
{
    input_string := RegExReplace(input_string,"([^'\d])","$1'")
    input_string := StrReplace(input_string,"''","'")
    input_string := RegExReplace(input_string,"'(\d)","$1")
    input_string := RTrim(input_string, "'")
    return input_string
}

Assert(GetSimpleSpellString("wxhn") == "w'x'h'n",,,1)
Assert(GetSimpleSpellString("w'x'h'n") == "w'x'h'n",,,1)
Assert(GetSimpleSpellString("w3x3h1n3") == "w3x3h1n3",,,1)
Assert(GetSimpleSpellString("w3x3h1n") == "w3x3h1n",,,1)
; Assert(GetSimpleSpellString("wo3xi3huan1n3") == "w3x3h1n3",,,1)

