;*******************************************************************************
; 辅助码相关
;
PinyinResultShowAuxiliary(ByRef search_result)
{
    local
    loop % search_result.Length()
    {
        if( InStr(search_result[A_Index, 0], "pinyin|") && (search_result[A_Index, 6]=="") ){
            search_result[A_Index, 6] := GetAuxiliaryTable(search_result[A_Index, 2])
        }
    }
}

; 辅助码构成反查
GetAuxiliaryTable(str)
{
    local
    global srf_fzm_fancha_table ; TODO
    len := StrLen(str)
    if( len==1 )
    {
        return srf_fzm_fancha_table[str]
    }
    else if( len>4 )
    {
        return
    }

    result := ""
    ; 每字第一码
    loop, Parse, str
    {
        result .= SubStr(srf_fzm_fancha_table[A_LoopField], 1, 1)
    }
    ; 词末字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,0,1)]
    ; 首字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,1,1)]
    return result
}

PinyinResultCheckAuxiliary(ByRef search_result, tfzm)
{
    global history_field_array
    dwselect := 1

    if( tfzm )
    {
        found_result := []
        loop % search_result.Length()
        {
            ; "i)" before the regular expression means that the match is case-insensitive
            if( (search_result[A_Index,6] ~= "i)^" . tfzm) || (StrLen(search_result[A_Index,2])>1 && search_result[A_Index,6]~="i)" . RegExReplace(tfzm,"(.)","$1(.*)?")) )
            {
                search_result[A_Index, -2] := dwselect ? tfzm : search_result[A_Index,6]
                found_result.Push(search_result[A_Index])
            }
            else
            {
                search_result[A_Index].Delete(-2)
            }
        }

        if( found_result.Length() )
        {
            search_result := found_result
        }
    }
}
