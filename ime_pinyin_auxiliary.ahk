;*******************************************************************************
; 辅助码相关
;
PinyinAuxiliaryInitialize()
{
    global auxiliary_table := []

    ; This code is too slow, I commented it out just for future reference
    ; Loop
    ; {
    ;     FileReadLine, line_content, test-spilt-character.txt, %A_Index%
    ;     if ErrorLevel
    ;         break
    ;     StringSplit, arr, line_content, `t
    ;     auxiliary_table[arr1] := arr2
    ; }

    FileRead, file_content, test-spilt-character.txt
    index := 0
    Loop, Parse, file_content, `n
    {
        index += 1
        ; Split each line by the tab character
        arr := StrSplit(A_LoopField, A_Tab,, 2)
        
        ; Store the first word as the key and the rest as the value
        data := RegExReplace(arr[2], "[ `n`r]")
        data := StrSplit(data, A_Tab)
        auxiliary_table[arr[1]] := data
    }
    ; MsgBox, % index
}

PinyinResultShowAuxiliary(ByRef search_result)
{
    local
    loop % search_result.Length()
    {
        if( search_result[A_Index, 6] == "" )
        {
            search_result[A_Index, 6] := GetAuxiliaryTable(search_result[A_Index, 2])
        }
    }
}

; 辅助码构成反查
GetAuxiliaryTable(str, max_cnt:=1)
{
    local
    global auxiliary_table
    len := StrLen(str)
    result := ""
    if( len == 1 )
    {
        loop, % max_cnt
        {
            code := auxiliary_table[str, A_Index]
            if( code ){
                result .= result ? "," : ""
                result .= SubStr(code, 1, 1) . SubStr(code, 0, 1)
            }
        }
    }
    else
    {
        ; 每字第一码
        loop, Parse, str
        {
            code := auxiliary_table[A_LoopField, 1]
            result .= SubStr(code, 1, 1)
        }
    }
    return result
}

PinyinResultCheckAuxiliary(ByRef search_result, auxiliary_code)
{
    local
    global tooltip_debug

    if( auxiliary_code )
    {
        begin_tick := A_TickCount
        found_result := []
        loop % search_result.Length()
        {
            ; Assert(StrLen(search_result[A_Index,2])>1, search_result[A_Index,2] "," search_result[A_Index,1])
            ; "i)" before the regular expression means that the match is case-insensitive
            ; a := search_result[A_Index,6] ~= "i)^" . auxiliary_code
            ; b := StrLen(search_result[A_Index,2])>=1
            ; c := search_result[A_Index,6] ~= "i)" . RegExReplace(auxiliary_code,"(.)","$1(.*)?")
            content_auxiliary := InStr(search_result[A_Index,6], auxiliary_code)
            same_as_auxiliary := auxiliary_code == search_result[A_Index, 2]
            if( content_auxiliary || same_as_auxiliary )
            {
                found_result.Push(search_result[A_Index])
            }
        }

        if( found_result.Length() )
        {
            search_result := found_result
        }
        
        tooltip_debug[6] := "Auxiliary tick: " A_TickCount - begin_tick ", " found_result.Length() " [" auxiliary_code "]"
    }
}
