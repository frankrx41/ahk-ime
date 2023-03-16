#NoEnv
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
#Include, ime_pinyin_get_result.ahk
#Include, ime_pinyin_split.ahk
#Include, ime_db.ahk
#Include, lib\JSON.ahk
#Include, ime_func.ahk
#Include, lib\SQLiteDB.ahk
PinyinInit()


PinyinSqlGetResult("", PinyinSplit("n1a1"))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang"))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang "))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang4"))
PinyinSqlGetResult("", PinyinSplit("woaini"))
PinyinSqlGetResult("", "wo'ai'ni3")
