#NoEnv
#Warn
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#Include, ime_pinyin.ahk
#Include, ime_assert.ahk
#Include, ime_pinyin_phrase.ahk
#Include, ime_pinyin_combine.ahk
#Include, ime_pinyin_process.ahk
#Include, ime_pinyin_assistant.ahk
#Include, ime_pinyin_simple_spell.ahk
#Include, ime_pinyin_associate.ahk
#Include, ime_db.ahk
#Include, lib\JSON.ahk
#Include, ime_func.ahk
#Include, lib\SQLiteDB.ahk
#Include, ime_candidate.ahk

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

candidate := new Candidate
candidate.Initialize("wo kaixin a")
; candidate.Initialize("wo     xihuanni")
candidate.Initialize("zhzh")
candidate.Initialize("wxh")
candidate.Initialize("wtyan")
candidate.SetSelectIndex(2)
candidate.GetSendSelectWord()
