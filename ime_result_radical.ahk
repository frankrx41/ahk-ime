;*******************************************************************************
; 辅助码相关
;
PinyinRadicalInitialize()
{
    local
    global ime_radical_table := {}
    global ime_radicals_pinyin := {}

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n, `r
    {
        if( SubStr(A_LoopField, 1, 1) != ";" )
        {
            ; Split each line by the tab character
            arr := StrSplit(A_LoopField, A_Tab,, 2)
            data := StrSplit(arr[2], " ")
            ime_radical_table[arr[1]] := data
        }
    }
    Assert(ime_radical_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    Loop, Parse, file_content, `n, `r
    {
        if( SubStr(A_LoopField, 1, 1) != ";" )
        {
            arr := StrSplit(A_LoopField, " ")
            ime_radicals_pinyin[arr[1]] := arr[2]
        }
    }
    Assert(ime_radicals_pinyin.Count() != 0)
}

; 辅助码构成反查
; "派" -> ["氵", "𠂢"]
PinyinRadicalWordGetRadical(single_word)
{
    global ime_radical_table
    return ime_radical_table[single_word]
}

PinyinRadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
    return ime_radicals_pinyin[single_radical]
}

PinyinRadicalIsAtomic(single_word)
{
    static radical_atomic := "丨亅丿乛一乙乚丶匕冫丷厂刀刂儿阝几卩冂力冖凵人亻入厶亠匸讠廴又艹屮彳巛川辶寸大飞工弓廾己彐彑巾口马门宀女犭山彡尸饣士扌氵纟巳土囗兀夕小忄幺弋尢夂子贝灬长车歹斗方风父戈卝户戶戸火见斤耂毛木肀牛牜爿片攴攵气欠犬日氏礻手殳水瓦王韦文毋心牙曰月爫支止爪白癶甘瓜禾钅立龙矛皿母目疒鸟皮生石矢示罒田玄疋业衤臣虫而耳缶艮虍臼米齐肉色舌覀页先血羊聿至舟衣竹自羽糸糹貝采镸車辰赤辵豆谷見角克里卤麦身豕辛言邑酉酋豸走足靑雨齿長非阜金釒隶門靣飠鱼隹風革骨鬼韭面首韋香頁音"
    return InStr(radical_atomic, single_word)
}

PinyinRadicalIsFirstPart(test_radical, test_word)
{
    radical_word_list := PinyinRadicalWordGetRadical(test_word)
    first_word := radical_word_list[1]
    test_pinyin := PinyinRadicalGetPinyin(first_word)
    return SubStr(test_radical, 1, 1) == test_pinyin
}

PinyinRadicalIsLastPart(test_radical, test_word)
{
    radical_word_list := PinyinRadicalWordGetRadical(test_word)
    last_word := radical_word_list[radical_word_list.Length()]
    test_pinyin := PinyinRadicalGetPinyin(last_word)
    return InStr(test_pinyin, SubStr(test_radical, 0, 1))
}


; "CR" + "幕" -> ""
; "CCC" + "艹" -> "CC"
PinyinResultIsAllPartOfRadical(test_radical, test_word)
{
    radical_word_list := CopyObj(PinyinRadicalWordGetRadical(test_word))
    loop
    {
        if( test_radical == "" ){
            return true
        }
        if( radical_word_list.Length() == 0 || ){
            return false
        }

        has_part_same := false

        ; Check first word
        if( !has_part_same )
        {
            first_word := radical_word_list[1]
            test_pinyin := PinyinRadicalGetPinyin(first_word)
            if( SubStr(test_radical, 1, 1) == test_pinyin || SubStr(test_radical, 0, 1) == test_pinyin ) {
                test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
                radical_word_list.RemoveAt(1)
                has_part_same := true
            }
        }

        ; Check last word
        if( !has_part_same )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            test_pinyin := PinyinRadicalGetPinyin(last_word)
            if( SubStr(test_radical, 1, 1) == test_pinyin || SubStr(test_radical, 0, 1) == test_pinyin ) {
                test_radical := StrReplace(test_radical, test_pinyin, "",, 1)
                radical_word_list.RemoveAt(radical_word_list.Length())
                has_part_same := true
            }
        }

        ; Check if is part of first char
        ; e.g. 干 -> 二 丨, "一" H and "二" E both think match
        if( !has_part_same )
        {
            first_word := radical_word_list[1]
            if( !PinyinRadicalIsAtomic(first_word) && PinyinRadicalIsFirstPart(test_radical, first_word) )
            {
                test_radical := SubStr(test_radical, 2)
                radical_word_list.RemoveAt(1)
                has_part_same := true
            }
        }

        ; e.g. 肉 -> 冂 仌, "人" R will also be match
        if( !has_part_same )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            if( !PinyinRadicalIsAtomic(last_word) && PinyinRadicalIsLastPart(test_radical, last_word) )
            {
                test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
                radical_word_list.RemoveAt(radical_word_list.Length())
                has_part_same := true
            }
        }

        if( !has_part_same )
        {
            return false
        }
    }
}

; radical_list: ["SS", "YZ", "RE"]
PinyinResultFilterByRadical(ByRef search_result, radical_list)
{
    local

    if( radical_list )
    {
        ImeProfilerBegin(26)
        index := 1
        loop % search_result.Length()
        {
            word_value := search_result[index, 2]
            sould_remove := false
            ; loop each character of "我爱你"
            loop % search_result[index, 5]
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    if( !PinyinResultIsAllPartOfRadical(test_radical, test_word) )
                    {
                        sould_remove := true
                    }
                }
                if( sould_remove ){
                    break
                }
            }

            if( sould_remove ) {
                search_result.RemoveAt(index)
            } else {
                index += 1
            }
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
        ImeProfilerEnd(26)
    }
}
