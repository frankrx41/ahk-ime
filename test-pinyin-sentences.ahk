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
#Include, ime_pinyin_auxiliary.ahk
#Include, ime_pinyin_simple_spell.ahk
#Include, ime_pinyin_associate.ahk
#Include, ime_db.ahk
#Include, lib\JSON.ahk
#Include, ime_func.ahk
#Include, lib\SQLiteDB.ahk

global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
PinyinInit()
ImeDBInitialize()
global tooltip_debug := []
global history_field_array := []

debug_tip := ""
tooltip_debug := []


; Add your debug code here
tooltip_debug[1] := ">>"
result := PinyinGetSentences("buneng")
Msgbox, % tooltip_debug[1]
ExitApp
result := PinyinGetSentences("wxhn")
result := PinyinGetSentences("wxhns")
result := PinyinGetSentences("wxhnsa") ; "wxhn" + "sa"
result := PinyinGetSentences("woxihuan") ; "woxihuan"
result := PinyinGetSentences("woxihuann")
result := PinyinGetSentences("w")
result := PinyinGetSentences("wo")
result := PinyinGetSentences("woh")
result := PinyinGetSentences("woh")
result := PinyinGetSentences("wohe")
result := PinyinGetSentences("wohen")
result := PinyinGetSentences("woxihuan")
result := PinyinGetSentences("woxihuanni")
result := PinyinGetSentences("zhrmghg")
result := PinyinGetSentences("hen")
result := PinyinGetSentences("wxhn")
result := PinyinGetSentences("wxh")
result := PinyinGetSentences("wxhn")
result := PinyinGetSentences("kaixina")
result := PinyinGetSentences("zh")
result := PinyinGetSentences("woai")
result := PinyinGetSentences(".x")
result := PinyinGetSentences("hhhhwo")
result := PinyinGetSentences("hhhhhhhhh")
result := PinyinGetSentences("laoshuru")
result := PinyinGetSentences("woshei")
result := PinyinGetSentences("wo")
result := PinyinGetSentences("woxihuanni")
result := PinyinGetSentences("zhrm")
for _, value in tooltip_debug {
    debug_tip .= "`n" value
}
Msgbox, % debug_tip

tooltip_debug := []
result := PinyinGetSentences("zhh")
for _, value in tooltip_debug {
    debug_tip .= "`n" value
}
Msgbox, % debug_tip

result := PinyinGetSentences("zhh")
result := PinyinGetSentences("hh")
result := PinyinGetSentences("cjjphhhh")
result := PinyinGetSentences("w")
result := PinyinGetSentences("wo")
result := PinyinGetSentences("wohaoxihuanni")
result := PinyinGetSentences("wuhui")
result := PinyinGetSentences("hao")
result := PinyinGetSentences("wuhui")
