#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

;OPTIMIZATIONS START
#MaxHotkeysPerInterval 99000000
#HotkeyInterval 99000000
#KeyHistory 0
ListLines Off
Process, Priority, , A
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetDefaultMouseSpeed, 0
SetWinDelay, -1
SetControlDelay, -1
SendMode Input
; DllCall("ntdll\ZwSetTimerResolution","Int",5000,"Int",1,"Int*",MyCurrentTimerResolution) ;setting the Windows Timer Resolution to 0.5ms, THIS IS A GLOBAL CHANGE
;OPTIMIZATIONS END

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
ImeProfilerFunc("ImeDebugLevelInitialize")
ImeProfilerFunc("ImeInputterInitialize")
ImeProfilerFunc("ImeOutputterInitialize")

; Selector
ImeProfilerFunc("ImeSelectMenuInitialize")
ImeProfilerFunc("ImeSelectorInitialize")

; Translator
ImeProfilerFunc("ImeCandidateInitialize")
ImeProfilerFunc("ImeTranslatorHistoryInitialize")
ImeProfilerFunc("ImeTranslatorLongPinyinInitialize")

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
; Tooltip, % ImeProfilerGetProfileText("MainInitialize") "`n " ImeProfilerGetTotalTick("MainInitialize")
return

;*******************************************************************************
;
#Include, src\ime_include.ahk
