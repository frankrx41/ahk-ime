#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force

CoordMode, ToolTip, Screen
CoordMode, Caret, Screen
CoordMode, Mouse, Screen
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
}
SetTitleMatchMode, 2 ; For WinActive(A_ScriptName)
DetectHiddenWindows, On

;*******************************************************************************
; Global variable
global DllFolder    := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
global ime_version  := 0.10

;*******************************************************************************
; Initialize
ImeProfilerInitialize()

; ImeProfilerBegin(1)
ImeProfilerFunc(1, "ImeInputterInitialize")
ImeProfilerFunc(1, "ImeOutputterInitialize")

; Selector
ImeProfilerFunc(1, "ImeSelectMenuInitialize")
ImeProfilerFunc(1, "ImeSelectorInitialize")

; Translator
ImeProfilerFunc(1, "ImeCandidateInitialize")
ImeProfilerFunc(1, "TranslatorHistoryInitialize")

; Radical
ImeProfilerFunc(1, "RadicalInitialize")

ImeProfilerFunc(1, "PinyinInitialize")
ImeProfilerFunc(1, "GojuonTranslateInitialize")
ImeProfilerFunc(1, "ImeTooltipInitialize")
ImeProfilerFunc(1, "ImeHotkeyInitialize")
; We need to declare some variables then `ImeStateUpdateMode` used
; `ImeStateUpdateMode` is call inside `ImeStateInitialize`
ImeProfilerFunc(1, "ImeStateInitialize")

ImeProfilerFunc(1, "ImeDBInitialize")

; We should register hotkey after other modules are initialized
ImeProfilerFunc(1, "ImeHotkeyRegisterInitialize")

; Tooltip, % ImeProfilerGetDebugInfo(1) "`n " ImeProfilerGetTotalTick(1)
return

;*******************************************************************************
;
#Include, src\ime_include.ahk
