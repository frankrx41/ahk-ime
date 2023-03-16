#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

#include, ime_pinyin_assistant.ahk
#include, ime_func.ahk
#include, ime_assert.ahk

PinyinAssistantInitialize()

; Display the dictionary contents for testing

; MsgBox, % assistant_table.Length()
; for key, value in assistant_table
; {
;     MsgBox % A_Index ", " "Key: " key "`nValue: " value
;     if( A_Index > 5 ){
;         Break
;     }
; }

Msgbox, % GetAssistantTable("我")
Msgbox, % GetAssistantTable("爱")
Msgbox, % GetAssistantTable("你")