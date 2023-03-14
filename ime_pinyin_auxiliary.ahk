PinyinProcess6(ByRef search_result, fuzhuma)
{
    local
    if( fuzhuma )
    {
        loop % search_result.Length() {
            if( InStr(search_result[A_Index, 0], "pinyin|") && (search_result[A_Index, 6]=="") ){
                search_result[A_Index, 6] := fzmfancha(search_result[A_Index, 2])
            }
        }
    }
}

; 辅助码构成规则
fzmfancha(str)
{
    local
    global srf_fzm_fancha_table
    if (len:=StrLen(str))=1
        return srf_fzm_fancha_table[str]
    else if len>4
        return
    result:=""
    ; 每字第一码
    loop, Parse, str
        result .= SubStr(srf_fzm_fancha_table[A_LoopField], 1, 1)
    ; 词末字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,0,1)]
    ; 首字辅助
    ; result := srf_fzm_fancha_table[SubStr(str,1,1)]
    return result
}
