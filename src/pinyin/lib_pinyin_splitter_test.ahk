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
        msg_string .= "`n""" input_case """ -> [" SplitterResultListGetDebugText(test_result) "] (" auto_complete ")"
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
