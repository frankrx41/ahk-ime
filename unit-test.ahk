#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%


PinyinInitialize()
global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
ImeDBInitialize()
ImeTranslatorClear()
ImeProfilerInitialize()
TranslatorHistoryClear()
RadicalInitialize()

PinyinSplitterInputStringUnitTest()
ExitApp


#Include, ime_include.ahk
