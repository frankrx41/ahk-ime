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
PinyinInitialize()
global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
ImeDBInitialize()

PinyinSplit("jin1",, DB)
PinyinSplit("enen",, DB)
PinyinSplit("angan",, DB)
PinyinSplit("haoa",, DB)
PinyinSplit("ang",, DB)
PinyinSplit("yingen",, DB)
PinyinSplit("nn",, DB)

PinyinSqlGetResult(DB, PinyinSplit("wu3hui1"))

PinyinSplit("enenan",, DB)
PinyinSplit("enan",, DB)
PinyinSplit("enenanan",, DB)

PinyinSplit("yeran",, DB)
PinyinSplit("eri",, DB)
PinyinSplit("enen",, DB)
PinyinSplit("en1en1",, DB)
PinyinSplit("keyi")
PinyinSplit("shijian")
PinyinSplit("nuni")
PinyinSplit("n")


GetSimpleSpellString2(input_string)
{
    input_string := RegExReplace(input_string,"([a-z])(?=[^'\d])","$1'")
    input_string := RTrim(input_string, "'")
    input_string := RegExReplace(input_string,"(['\d])","%$1")
    return input_string
}

GetSimpleSpellString2("wu3hui1'")
GetSimpleSpellString2("wo3ai4ni'")
GetSimpleSpellString2("wo3ai4ni")
PinyinSplit("zhzhzhzh")
PinyinSplit("lon")
PinyinSqlGetResult("", PinyinSplit("zhzhzhzh"))
PinyinSqlGetResult("", PinyinSplit("n1a1"))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang"))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang "))
PinyinSqlGetResult("", PinyinSplit("zhishizheyang4"))
PinyinSqlGetResult("", PinyinSplit("woaini"))
PinyinSqlGetResult("", "wo'ai'ni3")
