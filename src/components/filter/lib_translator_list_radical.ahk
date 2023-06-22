;*******************************************************************************
; Radical
;
RadicalInitialize()
{
    local
    global ime_radical_table    := {}   ; data\radicals.txt
    global ime_radicals_pinyin  := {}   ; radicals-pinyin.txt
    global ime_radical_atomic   := "一丨丿乀丶𠄌乁乛㇕乙𠃊乚亅㇆勹㇉𠃋匚匸冂凵⺆巜龴厶艹冖罓宀罒㓁癶覀𤇾𦥯龷皿亻彳阝牜衤飠纟犭丩丬礻讠訁扌忄饣釒钅爿豸刂卩卪厂广虍疒⺈弋廴辶㔾𠂔疋肀𠔉𠤏𡿺叵囙夨夬屮丱彑𠂢旡歺辵尢夂匕刀儿几力人入又川寸大飞工弓己已巾口囗马门女山尸士巳兀夕小幺子贝长车斗方风父戈户戸戶火见斤毛木牛片气日氏手殳水瓦王韦文毋心牙曰月支止爪白甘瓜禾立龙矛母目鸟皮生石矢示田玄业臣虫而耳缶艮臼米齐肉色舌页先血聿至舟竹⺮自羽貝采镸車辰赤豆谷見角克里卤麦身豕辛言邑酉酋走足靑雨齿非金隶鱼鬼韭面首韋頁龹𠂉用电乃为了九万丁个丫不上下冫氵⺌⺗⻊巛灬"
    global ime_radical_must_first    := "艹冖罓宀罒㓁癶亻彳阝牜衤飠纟犭丩丬礻讠訁扌忄饣釒钅爿豸厂广耂虍疒⺈廴辶"

    ime_radical_table := ReadFileToTable("data\radicals.asm", "`t", "`t", " ")
    ime_radicals_pinyin := ReadFileToTable("data\radicals-pinyin.asm", "`t", " ", "")
}

;*******************************************************************************
; "里" -> [["田", "土"], ["甲", "二"]]
RadicalWordSplit(single_word)
{
    global ime_radical_table
    ; Assert(ime_radical_table.HasKey(single_word), single_word, false)
    return ime_radical_table[single_word]
}

RadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
    Assert(single_radical != "", "", false)
    Assert(ime_radicals_pinyin.HasKey(single_radical), "Miss pinyin for """ single_radical ", " Asc(single_radical) """", false)
    return ime_radicals_pinyin[single_radical]
}

RadicalIsMatchPinyin(radical, test_pinyin)
{
    local
    radical_pinyin_list := RadicalGetPinyin(radical)
    for index, element in radical_pinyin_list
    {
        if( element == test_pinyin ){
            return true
        }
    }
    return false
}

; Atomic radical should no continue split
RadicalIsAtomic(single_word)
{
    global ime_radical_atomic
    return InStr(ime_radical_atomic, single_word)
}

RadicalIsMustFirst(single_word)
{
    global ime_radical_must_first
    return InStr(ime_radical_must_first, single_word)
}

DebugRadicalRecordMissWord(word)
{
    word := word "`n"
    FileAppend, %word%, .\miss_radicals.log
}

;*******************************************************************************
;
;*******************************************************************************
;
RadicalCheckMatchRadicalLevel(test_word, test_radical)
{
    local
    ; ImeProfilerBegin()

    match_level := 0
    if( !RadicalIsAtomic(test_word) )
    {
        radical_word_list := RadicalWordSplit(test_word)
        if( !(radical_word_list.Length() != 0 && radical_word_list != "") )
        {
            DebugRadicalRecordMissWord(test_word)
        }

        loop, % radical_word_list.Length()
        {
            result_level := RadicalIsFullMatchList(radical_word_list[A_Index], test_radical)
            match_level := Max(result_level, match_level)
        }
    }
    else
    {
        match_level := 0
    }

    return match_level
}

;*******************************************************************************
;
; e.g. 干 -> 二 丨, "一" H and "二" E both think match
RadicalMatchFirstPart(test_word, ByRef test_radical, ByRef remain_radicals)
{
    local
    Assert( test_word, test_word, "msgbox" )

    can_continue_split := false
    if( !RadicalIsAtomic(test_word) )
    {
        radical_word_list := RadicalWordSplit(test_word)
        if( !(radical_word_list.Length() != 0 && radical_word_list != "") )
        {
            ; radical_word_list := RadicalWordSplit(GetSimplifiedWord(test_word))
            if( !(radical_word_list.Length() != 0 && radical_word_list != "") )
            {
                DebugRadicalRecordMissWord(test_word)
            }
        }
        loop, % radical_word_list.Length()
        {
            first_word := radical_word_list[A_Index, 1]
            if( RadicalIsMatchPinyin(first_word, SubStr(test_radical, 1, 1)) ){
                can_continue_split := true
                break
            }
        }
    }

    if( !can_continue_split )
    {
        if( RadicalIsMatchPinyin(test_word, SubStr(test_radical, 1, 1)) ) {
            test_radical := SubStr(test_radical, 2)
            return true
        }
        if( RadicalIsAtomic(test_word) ){
            return false
        }
    }

    ; Backup
    test_radical_backup := test_radical
    remain_radicals_backup := CopyObj(remain_radicals)

    radical_word_list := RadicalWordSplit(test_word)
    loop, % radical_word_list.Length()
    {
        loop_radical_index := A_Index
        first_word := radical_word_list[loop_radical_index, 1]
        Assert(first_word != test_word, test_word, "msgbox")

        test_radical := test_radical_backup
        remain_radicals := CopyObj(remain_radicals_backup)
        remain_radicals_length := remain_radicals.Length()
        loop, % radical_word_list[loop_radical_index].Length()-1
        {
            remain_radicals[remain_radicals_length+A_Index] := radical_word_list[loop_radical_index, A_Index+1]
        }

        if( RadicalMatchFirstPart(first_word, test_radical, remain_radicals) )
        {
            return true
        }
    }

    return false
}

;*******************************************************************************
; return:
;   +-------+-----------+-------+
;   | word  | radical   | %     |
;   +-------+-----------+-------+
;   | 召    | DK        | 100   |
;   | 照    | DK        | 100   |
;   | 召    | K         | 100   |
;   | 树    | C         | 100   |
;   part match          DK
;   match last         召 K  C
;   no match
;   have no radical    一
RadicalIsFullMatchList(original_radical_word_list, test_radical)
{
    local
    skip_able_count     := 3
    final_match_level   := 1
    radical_word_list   := CopyObj(original_radical_word_list)
    loop
    {
        if( test_radical == "" ){
            break
        }
        if( radical_word_list.Length() == 0 ){
            final_match_level := 0
            break
        }

        ; Check if is part of first char
        skip_count := 0
        loop, % skip_able_count
        {
            match_level := 0
            check_index := A_Index
            if( check_index > radical_word_list.Length() ) {
                break
            }
            first_word := radical_word_list[check_index]
            Assert(first_word, "> " check_index ", " first_word, "msgbox")


            max_radical_check_length := 0
            match_level := RadicalIsMatchPinyin(first_word, SubStr(test_radical, 1, 1))
            if( match_level )
            {
                max_radical_check_length := 1
            }
            else
            {
                test_radical_len := RadicalIsAtomic(first_word) ? 1 : StrLen(test_radical)
                loop, % test_radical_len
                {
                    ; test_radical_check_length := test_radical_len - A_Index + 1
                    test_radical_check_length := A_Index
                    sub_test_radical := SubStr(test_radical, 1, test_radical_check_length)
                    result_level := RadicalCheckMatchRadicalLevel(first_word, sub_test_radical)
                    if( result_level > 0 && result_level >= match_level ) {
                        match_level := result_level
                        max_radical_check_length := test_radical_check_length
                    }
                    if( result_level == 0 && match_level > 0 ) {
                        break
                    }
                }
            }

            if( match_level != 0 ) {
                if( skip_count ) {
                    match_level /= skip_count
                }
                break
            } else {
                skip_count += 1
            }
        }

        final_match_level *= match_level
        if( match_level == 0 ) {
            break
        } else {
            test_radical := SubStr(test_radical, max_radical_check_length+1)
            radical_word_list.RemoveAt(check_index)
        }
    }

    level := 1 - (radical_word_list.Length() / original_radical_word_list.Length())
    Assert(level >= 0)
    return final_match_level * level
}

RadicalCheckWordClass(test_word, test_radical)
{
    if( InStr(test_radical, "!") && !IsVerb(test_word) ){
        return false
    }
    if( InStr(test_radical, "#") && !IsMeasure(test_word) && !IsNumeral(test_word) ){
        return false
    }
    if( InStr(test_radical, "^") && !IsFirstName(test_word)){
        return false
    }
    return true
}

;*******************************************************************************
; return:
;   0: No match         (No match word class or radical)
;   if have no radical but match word class, return 0.01
;   (0~1]: match level
RadicalCheckMatchLevel(test_word, test_radical)
{
    local
    ImeProfilerBegin()

    match_level := 0
    if( RadicalCheckWordClass(test_word, test_radical) )
    {
        ; You also need to update `GetRadical`
        test_radical := RegExReplace(test_radical, "[!@#$^&=]")
        radical_word_list := CopyObj(RadicalWordSplit(test_word))
        if( radical_word_list )
        {
            for index, element_list in radical_word_list
            {
                result_level := RadicalIsFullMatchList(element_list, test_radical)
                match_level := Max(result_level, match_level)
                if( match_level >= 1 ) {
                    break
                }
            }
        }
        else
        {
            ; If this word has no radical, set to 0.01 for sort at last
            match_level := 0.01
        }
    }

    ImeProfilerEnd()
    return match_level
}

RadicalCheckRepeatIsOk(words, radical_list)
{
    loop, % StrLen(words)
    {
        if( InStr(radical_list[A_Index], "=") && SubStr(words, A_Index, 1) != SubStr(words, A_Index-1, 1) )
        {
            return false
        }
    }
    return true
}

;*******************************************************************************
; radical_list: ["SS", "YZ", "RE"]
TranslatorResultListFilterByRadical(ByRef translate_result_list, radical_list)
{
    local
    ImeProfilerBegin()
    index := 1

    loop % translate_result_list.Length()
    {
        translate_result := translate_result_list[index]
        word_value      := TranslatorResultGetWord(translate_result)
        match_level     := 0
        word_length     := TranslatorResultGetWordLength(translate_result)
        if( RadicalCheckRepeatIsOk(word_value, radical_list) )
        {
            ; loop each character of "我爱你"
            loop % word_length
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    result_level := RadicalCheckMatchLevel(test_word, test_radical)
                    if( result_level == 0 ) {
                        match_level := 0
                        break
                    }
                    match_level := Max(result_level, match_level)
                }
                else
                {
                    match_level := 1
                }
            }
        }

        if( match_level ) {
            match_level := (word_length-1) * 1 + match_level
        }

        if( match_level == 0 ) {
            translate_result_list.RemoveAt(index, 1)
        } else {
            ; Fix sort
            match_level += TranslatorResultGetWeight(translate_result_list[index]) / 10000000
            TranslatorResultAddMatchLevel(translate_result_list[index], match_level)
            index += 1
        }
    }

    translate_result_list := ObjectSort(translate_result_list, 9, , true)

    if( translate_result_list.Length() == 0 )
    {
        translate_result_list.Push(TranslatorResultMakeError())
    }
    ImeProfilerEnd()
}
