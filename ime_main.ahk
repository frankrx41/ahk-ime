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
global ime_version  := "0.7.2"

;*******************************************************************************
; Initialize
ImeProfilerInitialize()

ImeProfilerBegin()
ImeProfilerFunc("ImeInputterInitialize")
ImeProfilerFunc("ImeOutputterInitialize")

; Selector
ImeProfilerFunc("ImeSelectMenuInitialize")
ImeProfilerFunc("ImeSelectorInitialize")

; Translator
ImeProfilerFunc("ImeCandidateInitialize")
ImeProfilerFunc("ImeTranslatorHistoryInitialize")

; Radical
ImeProfilerFunc("RadicalInitialize")

ImeProfilerFunc("PinyinInitialize")
ImeProfilerFunc("GojuonTranslateInitialize")
ImeProfilerFunc("ImeTooltipInitialize")
ImeProfilerFunc("ImeHotkeyInitialize")
; `ImeStateUpdateLanague` is call inside `ImeStateInitialize`
ImeProfilerFunc("ImeStateInitialize")

ImeProfilerFunc("ImeDBInitialize")

; We should register hotkey after other modules are initialized
ImeProfilerFunc("ImeHotkeyRegisterInitialize")

ImeProfilerEnd()
; Tooltip, % ImeProfilerGetDebugInfo("MainInitialize") "`n " ImeProfilerGetTotalTick("MainInitialize")
return

;*******************************************************************************
;
#Include, src\ime_include.ahk
