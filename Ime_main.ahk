#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"
}
SetTitleMatchMode, 2 ; For WinActive(A_ScriptName)
Menu, Tray, Tip, AHK Ime v0.02

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
global history_field_array := []
global save_field_array := []
global ime_for_select_obj := []
global srf_all_input_:=[]
Gosub, ImeInitialize
return

#Include, ime_func.ahk
#Include, ime_lib.ahk
#Include, ime_pinyin.ahk
#Include, ime_pinyin_phrase.ahk
#Include, ime_db.ahk
#Include, ime_tooltip.ahk
#Include, ime_hotkey.ahk
#Include, ime_input.ahk
#Include, ime_select.ahk
#Include, ime_state.ahk

#Include, lib\ToolTip.ahk
#Include, lib\SQLiteDB.ahk
#Include, lib\JSON.ahk

#if WinActive("AHK-Ime")
~^S::
Suspend
ToolTip, Reload %A_ScriptName%
Sleep, 500
Reload
return
#if
