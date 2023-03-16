#NoEnv
#Warn
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
PinyinInit()
ImeDBInitialize()

global tooltip_debug := []
global history_field_array := []

debug_tip := ""
tooltip_debug := []

PinyinInit()
ImeDBInitialize()
global tooltip_debug := []
global history_field_array := []

debug_tip := ""
tooltip_debug := []


ime_candidate := new Candidate
; ime_candidate.Initialize("wo kaixin a")
; ime_candidate.Initialize("wo     xihuanni")
; ime_candidate.Initialize("zhzh")
; ime_candidate.Initialize("wxh")
ime_candidate.Initialize("le1")
ime_candidate.SetSelectIndex(1)
ime_candidate.GetSendSelectWord()

ExitApp


#Include, ime_main.ahk
