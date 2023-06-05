#Include, src\pinyin\lib_pinyin_splitter_library.ahk
#Include, src\pinyin\lib_pinyin_splitter_simple.ahk
#Include, src\pinyin\lib_pinyin_splitter_normal.ahk
#Include, src\pinyin\lib_pinyin_splitter_double.ahk
#Include, src\pinyin\lib_pinyin_splitter_bopomofo.ahk
#Include, src\pinyin\lib_pinyin_splitter_fluent.ahk

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
PinyinSplitterInputString(input_string, simple_spell:=false, double_spell:=false, third_spell:=false, bopomofo_spell:=false)
{
    ; + or * marks 1 taken
    ; last char * marks simple spell

    if( simple_spell )
    {
        splitter_list := PinyinSplitterInputStringSimple(input_string)
    }
    else
    if( double_spell )
    {
        splitter_list := PinyinSplitterInputStringDouble(input_string)
    }
    else
    if( bopomofo_spell )
    {
        splitter_list := PinyinSplitterInputStringBopomofo(input_string)
    }
    else
    if( third_spell )
    {
        splitter_list := PinyinSplitterInputStringFluent(input_string)
    }
    else
    {
        splitter_list := PinyinSplitterInputStringNormal(input_string)
    }


    if( !simple_spell && !double_spell && !third_spell && StrLen(input_string) <= 4 && !InStr(input_string, "+") && !InStr(input_string, "%") )
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

