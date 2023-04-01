﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force

CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
}
SetTitleMatchMode, 2 ; For WinActive(A_ScriptName)

;*******************************************************************************
; Global variable
global DllFolder    := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
global ime_version  := 0.10

;*******************************************************************************
; Initialize
ImeProfilerInitialize()
ImeInputterInitialize()

; Selector
ImeSelectMenuInitialize()
ImeSelectorInitialize()

; Translator
ImeTranslatorInitialize()

ImeDBInitialize()
PinyinInitialize()

ImeTooltipInitialize()

ImeHotkeyInitialize()
; We need to declare some variables then `ImeStateUpdateMode` used
; `ImeStateUpdateMode` is call inside `ImeStateInitialize`
ImeStateInitialize()

; We should register hotkey after other modules are initialized
ImeHotkeyRegisterInitialize()
return

;*******************************************************************************
;
#Include, ime_include.ahk
