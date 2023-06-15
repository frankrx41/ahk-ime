;*******************************************************************************
; Radical
;
RadicalInitialize()
{
    local
    global ime_radical_table    := {}   ; data\radicals.txt
    global ime_radicals_pinyin  := {}   ; radicals-pinyin.txt
    global ime_radical_atomic   := "一丨丿乀丶𠄌乁乛㇕乙𠃊乚亅㇆勹㇉𠃋匚匸冂凵⺆巜龴厶艹冖罓宀罒㓁癶覀𤇾𦥯龷皿亻彳阝牜衤飠纟犭丩丬礻讠訁扌忄饣釒钅爿豸刂卩卪厂广虍疒⺈弋廴辶㔾𠂔疋肀𠔉𠤏𡿺叵囙夨夬屮丱彑𠂢旡歺辵尢夂匕刀儿几力人入又川寸大飞工弓己已巾口囗马门女山尸士巳兀夕小幺子贝长车斗方风父戈户戸戶火见斤毛木牛片气日氏手殳水瓦王韦文毋心牙曰月支止爪白甘瓜禾立龙矛母目鸟皮生石矢示田玄业臣虫而耳缶艮臼米齐肉色舌页先血羊聿至舟竹⺮自羽貝采镸車辰赤豆谷見角克里卤麦身豕辛言邑酉酋走足靑雨齿非金隶鱼鬼韭面首韋頁龹𠂉用电乃为了九万丁个丫不上下冫氵⺌⺗⻊巛"
    global ime_radical_must_first    := "艹冖罓宀罒㓁癶亻彳阝牜衤飠纟犭丩丬礻讠訁扌忄饣釒钅爿豸厂广耂虍疒⺈廴辶"

    ime_radical_table := ReadFileToTable("data\radicals.asm")
    ime_radicals_pinyin := ReadFileToTable("data\radicals-pinyin.asm")

    global radical_match_level_no_match      := 7
    global radical_match_level_no_radical    := 4
    global radical_match_level_last_match    := 3
    global radical_match_level_part_match    := 2    ; (include first match)
    global radical_match_level_full_match    := 1
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

RadicalCheckPinyin(radical, test_pinyin)
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

RadicalRecordMissWord(word)
{
    word := word "`n"
    FileAppend, %word%, .\miss_radicals.log
}

;*******************************************************************************
;
RadicalMatchFirstPart(test_word, ByRef test_radical, ByRef remain_radicals)
{
    local
    if( !test_word ){
        return true
    }

    try_continue_split := false
    if( !RadicalIsAtomic(test_word) )
    {
        radical_word_list := RadicalWordSplit(test_word)
        if( !(radical_word_list.Length() != 0 && radical_word_list != "") )
        {
            ; radical_word_list := RadicalWordSplit(GetSimplifiedWord(test_word))
            if( !(radical_word_list.Length() != 0 && radical_word_list != "") )
            {
                RadicalRecordMissWord(test_word)
            }
        }
        loop, % radical_word_list.Length()
        {
            first_word := radical_word_list[A_Index, 1]
            if( RadicalCheckPinyin(first_word, SubStr(test_radical, 1, 1)) ){
                try_continue_split := true
                break
            }
            if( !RadicalIsMustFirst(test_word) && RadicalCheckPinyin(first_word, SubStr(test_radical, 0, 1)) ){
                try_continue_split := true
                break
            }
        }
    }

    if( !try_continue_split )
    {
        if( RadicalCheckPinyin(test_word, SubStr(test_radical, 1, 1)) ) {
            test_radical := SubStr(test_radical, 2)
            return true
        }
        if( !RadicalIsMustFirst(test_word) && RadicalCheckPinyin(test_word, SubStr(test_radical, 0, 1)) ) {
            test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
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
;   full match         召 DK
;   part match         照 DK
;   match last         召 K 树 C
;   no match
;   have no radical    一
RadicalIsFullMatchList(test_word, test_radical, radical_word_list)
{
    local
    match_last_part := false
    ever_match_first := false

    global radical_match_level_no_match
    global radical_match_level_no_radical
    global radical_match_level_last_match
    global radical_match_level_part_match
    global radical_match_level_full_match

    skip_able_count := 1

    loop
    {
        if( radical_word_list.Length() == 0 && test_radical == "" ){
            return radical_match_level_full_match
        }
        if( test_radical == "" ){
            if( ever_match_first ){
                return radical_match_level_part_match
            } else {
                return radical_match_level_last_match
            }
        }
        if( radical_word_list.Length() == 0 ){
            return radical_match_level_no_match
        }

        match_any_part := false

        ; Check if is part of first char
        ; e.g. 干 -> 二 丨, "一" H and "二" E both think match
        if( !match_any_part )
        {
            loop, % skip_able_count
            {
                skip_able_index := A_Index
                first_word := radical_word_list[skip_able_index]
                remain_radicals := []
                if( RadicalMatchFirstPart(first_word, test_radical, remain_radicals) )
                {
                    ever_match_first := true
                    radical_word_list.RemoveAt(1, skip_able_index)
                    skip_able_count := 1
                    loop, % remain_radicals.Length()
                    {
                        radical_word_list.InsertAt(A_Index, remain_radicals[A_Index])
                        skip_able_count += 1
                    }
                    match_any_part := true
                    break
                }
            }
        }

        ; e.g. 肉 -> 冂 仌, "人" R will also be match
        if( !match_any_part && !match_last_part )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            remain_radicals := []
            if( RadicalMatchFirstPart(last_word, test_radical, remain_radicals) )
            {
                radical_word_list.RemoveAt(radical_word_list.Length())
                loop, % remain_radicals.Length()
                {
                    radical_word_list.Push(remain_radicals[A_Index])
                }
                match_any_part := true
                ; match_last_part := true
            }
        }

        if( !match_any_part )
        {
            return radical_match_level_no_match
        }
    }
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

RadicalCheckMatchLevel(test_word, test_radical)
{
    global radical_match_level_no_match
    global radical_match_level_no_radical
    global radical_match_level_last_match
    global radical_match_level_part_match
    global radical_match_level_full_match

    if( !RadicalCheckWordClass(test_word, test_radical) ){
        return radical_match_level_no_match
    }
    ; You also need to update `GetRadical`
    test_radical := RegExReplace(test_radical, "[!@#$%^&]")

    radical_word_list := CopyObj(RadicalWordSplit(test_word))
    if( !radical_word_list ){
        return radical_match_level_no_radical
    }
    match_level := radical_match_level_no_match
    for index, element in radical_word_list
    {
        result := RadicalIsFullMatchList(test_word, test_radical, element)
        if( result < match_level ){
            match_level := result
        }
        if( result == radical_match_level_full_match ){
            break
        }
    }
    return match_level
}

;*******************************************************************************
; radical_list: ["SS", "YZ", "RE"]
TranslatorResultListFilterByRadical(ByRef translate_result_list, radical_list)
{
    local
    global radical_match_level_no_match
    global radical_match_level_no_radical
    global radical_match_level_last_match
    global radical_match_level_part_match
    global radical_match_level_full_match

    need_filter := false
    for index, value in radical_list
    {
        if( value != "" ){
            need_filter := true
            break
        }
    }

    if( need_filter )
    {
        translate_full_match_result_list := []
        translate_last_match_result_list := []
        translate_no_radical_result_list := []

        index := 1
        loop % translate_result_list.Length()
        {
            translate_result := translate_result_list[index]
            ImeProfilerBegin()
            word_value := TranslatorResultGetWord(translate_result)
            should_remove   := false
            match_level     := radical_match_level_no_radical
            ; loop each character of "我爱你"
            loop % TranslatorResultGetWordLength(translate_result)
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    match_result := RadicalCheckMatchLevel(test_word, test_radical)
                    if( match_result == radical_match_level_no_match ) {
                        match_level := match_result
                        break
                    }
                    if( match_result < match_level ) {
                        match_level := match_result
                    }
                }
            }

            if( match_level == radical_match_level_full_match ) {
                translate_full_match_result_list.Push(translate_result)
            }
            if( match_level == radical_match_level_last_match ) {
                translate_last_match_result_list.Push(translate_result)
            }
            if( match_level == radical_match_level_no_radical ) {
                translate_no_radical_result_list.Push(translate_result)
            }

            if( match_level != radical_match_level_part_match ) {
                translate_result_list.RemoveAt(index)
            } else {
                index += 1
            }

            ImeProfilerEnd()
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "

        ; Show full match word first
        loop, % translate_full_match_result_list.Length()
        {
            translate_result_list.InsertAt(A_Index, translate_full_match_result_list[A_Index])
        }
        if( translate_last_match_result_list.Length() > 0 )
        {
            if( translate_result_list.Length() > 0 ) {
                translate_result_list.Push(TranslatorResultMakeDisable("", "----2-", ""))
            }
            loop, % translate_last_match_result_list.Length()
            {
                translate_result_list.Push(translate_last_match_result_list[A_Index])
            }
        }
        if( translate_no_radical_result_list.Length() )
        {
            if( translate_result_list.Length() > 0 ) {
                translate_result_list.Push(TranslatorResultMakeDisable("", "----3-", ""))
            }
            loop, % translate_no_radical_result_list.Length()
            {
                translate_result_list.Push(translate_no_radical_result_list[A_Index])
            }
        }

        if( translate_result_list.Length() == 0 )
        {
            translate_result_list.Push(TranslatorResultMakeError())
        }
    }
}
