;*******************************************************************************
; In:
;   spell:              a-z
;   tone:               "12345'" and {space}
;   radical:            A-Z
;   maybe has h sound:  ?
; Out:
;   spell:              a-z
;   tone:               012345
;   auto complete:      %
;   maybe has h sound:  ?
;
; Output always has a tone in last char
;
; e.g.
; "wo3ai4ni3" -> [wo3=3,ai4=2,ni3=1] (0)
; "woaini" -> [wo0=3,ai0=2,ni0=1] (0)
; "wo'ai'ni" -> [wo0=3,ai0=2,ni0=1] (0)
; "wo aini" -> [wo0=1,ai0=2,ni0=1] (0)
; "swalb1" -> [s%0=4,wa0=3,l%0=2,b%1=1] (0)
; "zhrmghg" -> [zh%0=6,r%0=5,m%0=4,g%0=3,h%0=2,g%0=1] (0)
; "taNde1B" -> [ta0{N}=2,de1{B}=1] (0)
; "z?eyangz?i3" -> [z?e0=3,yang0=2,z?i3=1] (0)
; "tzh" -> [t%0=3,z%0=2,h%0=1] (0)
; "zhe" -> [zhe0=1] (0)
; "haoN" -> [hao0{N}=1] (0)
;
; See: `PinyinSplitterInputStringTest`
PinyinSplitterInputString(input_string)
{
    ; + or * marks 1 taken
    ; last char * marks simple spell
    simple_spell := ImeSimpleSpellIsForce()

    if( simple_spell )
    {
        splitter_list := PinyinSplitterInputStringSimple(input_string)
    }
    else
    {
        splitter_list := PinyinSplitterInputStringNormal(input_string)
    }

    if( !simple_spell && StrLen(input_string) <= 4 && !InStr(input_string, "+") && !InStr(input_string, "%") )
    {
        try_simple_spliter := true
        loop, % splitter_list.Length()
        {
            if( SplitterResultIsCompleted(splitter_list[A_Index]) )
            {
                try_simple_spliter := false
                break
            }
        }
        if( try_simple_spliter )
        {
            splitter_list := PinyinSplitterInputStringSimple(input_string)
        }
    }

    return splitter_list
}

;*******************************************************************************
; Unit Test
PinyinSplitterInputStringTest()
{
    test_case := ["wo3ai4ni3", "woaini", "wo'ai'ni", "wo aini", "swalb1", "zhrmghg", "taNde1B", "z?eyangz?i3", "tzh", "zhe", "haoN"]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := PinyinSplitterInputString(input_case)
        auto_complete := "N/A"
        msg_string .= "`n""" input_case """ -> [" SplitterResultListGetDisplayText(test_result) "] (" auto_complete ")"
    }
    MsgBox, % msg_string
}

PinyinSplitterInputStringUnitTest()
{
    test_case := [ "banan","bingan","canan","changan","change","dingan","dinge","dongan","enai","enen","gangaotai","geren","gongan","heni","henai","jianao","jine","jingai","jinge","keneg","keneng","keren","kune","nanan","pingan","qiane","qinai","qingan","renao","shanao","shane","tigong","tiane","wanan","xianai","xieren","xieri","xinai","daxinganling","yanan","yiner","zhenai","zonge","wanou","lianai","bieren","buhuanersan","changanaotuo","wanganshi","zenmeneng","zenmerang","yixieren","naxieren","xigezao","xilegezao","xieriji" ]
    case_result := [ "ban'an","bing'an","can'an","chang'an","chang'e","ding'an","ding'e","dong'an","en'ai","en'en","gang'ao'tai","ge'ren","gong'an","he'ni","hen'ai","jian'ao","jin'e","jing'ai","jing'e","ke'neng","ke'neng","ke'ren","kun'e","nan'an","ping'an","qian'e","qin'ai","qing'an","re'nao","shan'ao","shan'e","ti'gong","tian'e","wan'an","xian'ai","xie'ren","xie'ri","xin'ai","da'xing'an'ling","yan'an","yin'er","zhen'ai","zong'e","wan'ou","lian'ai","bie'ren","bu'huan'er'san","chang'an'ao'tuo","wang'an'shi","zen'me'neng","zen'me'rang","yi'xie'ren","na'xie'ren","xi'ge'zao","xi'le'ge'zao","xie'ri'ji" ]
    msg_string := ""
    loop, % test_case.Length()
    {
        input_case := test_case[A_Index]
        test_result := PinyinSplitterInputString(input_case)
        result_str := ""
        loop, % test_result.Length()
        {
            result_str .= test_result[A_Index, 1] "'"
        }
        result_str := RTrim(result_str, "'")
        if(result_str != case_result[A_Index])
        {
            msg_string .= "`n[" input_case "] -> [" result_str "], [" case_result[A_Index] "]"
        }
    }
    MsgBox, % msg_string
}
