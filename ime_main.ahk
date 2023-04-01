#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force

CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
}
SetTitleMatchMode, 2 ; For WinActive(A_ScriptName)
Menu, Tray, Tip, AHK IME `nv0.09 (dev)

;*******************************************************************************
; Ime Initialize
global DllFolder        := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")

ImeProfilerInitialize()

ImeSelectMenuInitialize()

ImeSelectorInitialize()
ImeTranslatorInitialize()

ImeInputterInitialize()

ImeDBInitialize()
PinyinInitialize()
ImeHotkeyInitialize()

; tooltip
ime_tooltip_font_size           := 13
ime_tooltip_font_family         := "Microsoft YaHei Mono" ;"Ubuntu Mono derivative Powerline"
ime_tooltip_font_bold           := false
ime_tooltip_background_color    := "373832"
ime_tooltip_text_color          := "d4d4d4"
ToolTip(1, "", "Q0 B" ime_tooltip_background_color " T"  ime_tooltip_text_color " S" ime_tooltip_font_size, ime_tooltip_font_family, ime_tooltip_font_bold)

ImeStateInitialize()
ImeHotkeyRegisterInitialize()
return
;*******************************************************************************

#Include, ime_include.ahk
