#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance, force

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
CoordMode, ToolTip, Screen
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
if not A_IsAdmin
{
    Run *RunAs "%A_ScriptFullPath%"
}
SetTitleMatchMode, 2 ; For WinActive(A_ScriptName)
Menu, Tray, Tip, AHK IME `nv0.06 (dev)

#Include, ime_config.ahk

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
global tooltip_debug := []
Gosub, ImeInitialize
return

#Include, ime_assert.ahk
#Include, ime_func.ahk
#Include, ime_lib.ahk
#Include, ime_pinyin.ahk
#Include, ime_pinyin_phrase.ahk
#Include, ime_pinyin_combine.ahk
#Include, ime_pinyin_process.ahk
#Include, ime_pinyin_assistant.ahk
#Include, ime_pinyin_simple_spell.ahk
#Include, ime_pinyin_associate.ahk
#Include, ime_pinyin_get_result.ahk
#Include, ime_pinyin_split.ahk
#Include, ime_candidate.ahk
#Include, ime_db.ahk
#Include, ime_tooltip.ahk
#Include, ime_hotkey.ahk
#Include, ime_input.ahk
#Include, ime_select.ahk
#Include, ime_state.ahk

#Include, lib\ToolTip.ahk
#Include, lib\SQLiteDB.ahk
#Include, lib\JSON.ahk

#Include, ime_create_word.ahk

#if WinActive("AHK-Ime")
~^S::
Suspend
ToolTip, Reload %A_ScriptName%
Sleep, 500
Reload
return
#if
