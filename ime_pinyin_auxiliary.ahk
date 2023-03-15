;*******************************************************************************
; 辅助码相关
;
PinyinAuxiliaryInitialize()
{
    local
    global auxiliary_table := {}
    global auxiliary_pinyin := {}

    FileRead, file_content, data\character-spilt.txt
    Loop, Parse, file_content, `n
    {
        ; Split each line by the tab character
        arr := StrSplit(A_LoopField, A_Tab,, 2)
        
        ; Store the first word as the key and the rest as the value
        data := RegExReplace(arr[2], "[ `n`r]")
        data := StrSplit(data, A_Tab)
        auxiliary_table[arr[1]] := data
    }
    Assert(auxiliary_table.Count() != 0)

    FileRead, file_content, data\character-split-pinyin.txt
    index := 0
    Loop, Parse, file_content, `n
    {
        arr := StrSplit(A_LoopField)
        auxiliary_pinyin[arr[1]] := arr[2]
    }
    Assert(auxiliary_pinyin.Count() != 0)
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

PinyinAuxiliaryGetPinyin(auxiliary)
{
    local
    global auxiliary_pinyin
    result_pinyin := ""
    loop, Parse, % auxiliary
    {
        pinyin := auxiliary_pinyin[A_LoopField]
        Assert(pinyin)
        result_pinyin .= pinyin
    }
    return result_pinyin
}

PinyinResultCheckAuxiliary(ByRef search_result, auxiliary_code)
{
    local
    global tooltip_debug
    ; static auxiliary_table := [
        
    ; ,]

    if( auxiliary_code )
    {
        begin_tick := A_TickCount
        found_result := []
        loop % search_result.Length()
        {
            test_pinyin := PinyinAuxiliaryGetPinyin(search_result[A_Index,6])
            content_auxiliary := InStr(test_pinyin, auxiliary_code)
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
