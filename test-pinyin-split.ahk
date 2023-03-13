#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%



#Include, ime_pinyin.ahk
#Include, lib\JSON.ahk
#Include, ime_func.ahk

PinyinInit()
test_pinyin := [{"1": "angan", "2": "an'gan'"}
    ,{"1": "angeng", "2": "an'geng'"}
    ,{"1": "woaini", "2": "wo'ai'ni'"}
    ,{"1": "wo3ai4ni3", "2": "wo3ai4ni3"}
    ,{"1": "w3a4n3", "2": "w3a4n3"}
    
    ,{"1": "wAN", "2": "w'a'n'"}
    ,{"1": "maLiAo", "2": "ma'li'ao'"}
    ,{"1": "Wo", "2": "wo'"}
    ,{"1": "WoAiNi", "2": "wo'ai'ni'"}

    ,{"1": "wan", "2": "wan'"}
    ,{"1": "w", "2": "w'"}]


error_cnt := 0
total_cnt := 0
for index, item in test_pinyin
{
    ; MsgBox % "Element " index ": " value
    ; x := PinyinSplit(value) 
    ; MsgBox, %value% ":" %x%
    total_cnt += 1

    if( item["1"] == "wAN" ) {
        foo := 1
    }
    result := PinyinSplit(item["1"]) 


    if( result != item["2"] ) {
        error_cnt += 1
        MsgBox, % "Input: " item["1"] "`nHope: " item["2"] "`nGet: " result
    }
    ; for key, value in item
    ; {
    ;     ; Show the key and value
    ;     MsgBox % "Key: " key ", Value: " value
    ; }
}
MsgBox, % "Pass: " total_cnt-error_cnt " / " total_cnt
