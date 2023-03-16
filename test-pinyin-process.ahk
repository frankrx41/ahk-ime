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

arr := []
global DllFolder := A_ScriptDir "\dll\" (A_PtrSize=4?"x86":"x64")
history_field_array := []

PinyinInit()
ImeDBInitialize()

loop 4
{
    str := "wo'xi'huan'ni"
    str := PinyinSplit("ww")
    ; PinyinProcess3(DB,arr,str)
    x := GetLeftString(str, A_Index)
    MsgBox, % x
}
; ExitApp,

; Assert(x=="a1b1c1","",,1)
str := "a1b1c1d1e1f1"
x := GetLeftString(str, 1,3)
Assert(x=="a1b1c1","",,1)
x := GetLeftString(str, 2,3)
Assert(x=="a1b1","",,1)
x := GetLeftString(str, 3, 3)
Assert(x=="a1","",,1)
str := "wo'"
x := GetLeftString(str, 2)
Assert(x=="","",,1)




str := PinyinSplit("haxiquliyiquersanlipingtaisiwujia")
str := PinyinSplit("yiersansiwuliuqibajiushigeshibaiqianwan")
x := GetLeftString(str, 2)

str := PinyinSplit("wo")
PinyinProcess3(DB,arr,str)
str := PinyinSplit("wo3ai4ni3")
PinyinProcess3(DB,arr,str)
str := PinyinSplit("haxiquliaaaaaaaaaaaaaaaaaaaaaa")
PinyinProcess3(DB,arr,str)

