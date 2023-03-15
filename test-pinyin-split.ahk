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
global tooltip_debug := []
PinyinInit()

; Add your debug code here
result := PinyinSplit("gan3jue2")
result := PinyinSplit("wo ai ni")



; Unit test
test_pinyin := [{"1": "angan", "2": "'an'gan'"}
    ,{"1": "wo ai ni", "2": "'wo'ai'ni'" }
    ,{"1": "zh", "2": "'zh'" }
    ,{"1": "zhzh", "2": "'zh'zh'" }
    ,{"1": "angeng", "2": "'an'geng'"}
    ,{"1": "woaini", "2": "'wo'ai'ni'"}
    ,{"1": "wo3ai4ni3", "2": "'wo3ai4ni3"}
    ,{"1": "w3a4n3", "2": "'w3a4n3"}
    
    ,{"1": "wAN", "2": "'w'a'n'"}
    ,{"1": "maLiAo", "2": "'ma'li'ao'"}
    ,{"1": "Wo", "2": "'wo'"}
    ,{"1": "WoAiNi", "2": "'wo'ai'ni'"}

    ,{"1": "wan", "2": "'wan'"}
    ,{"1": "w", "2": "'w'"}]


error_cnt := 0
total_cnt := 0
for index, item in test_pinyin
{
    total_cnt += 1
    result := PinyinSplit(item["1"]) 
    if( result != item["2"] ) {
        error_cnt += 1
        MsgBox, % "Input: " item["1"] "`nHope: " item["2"] "`nGet: " result
    }
}
MsgBox, % "Pass: " total_cnt-error_cnt " / " total_cnt
