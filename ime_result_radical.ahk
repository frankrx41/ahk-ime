;*******************************************************************************
; Radical
;
RadicalInitialize()
{
    local
    global ime_radical_table    := {}
    global ime_radicals_pinyin  := {}
    global ime_radical_atomic   := ""

    FileRead, file_content, data\radicals.txt
    Loop, Parse, file_content, `n, `r
    {
        if( SubStr(A_LoopField, 1, 1) != ";" )
        {
            ; Split each line by the tab character
            line_arr := StrSplit(A_LoopField, A_Tab,, 2)
            radicals_arr := StrSplit(line_arr[2], A_Tab)
            data := []
            for index, element in radicals_arr
            {
                data.Push(StrSplit(element, " "))
            }
            ime_radical_table[line_arr[1]] := data
        }
    }
    Assert(ime_radical_table.Count() != 0)

    FileRead, file_content, data\radicals-pinyin.txt
    index := 0
    radical_atomic_start := true
    Loop, Parse, file_content, `n, `r
    {
        line := A_LoopField
        if( line == "#radical_atomic_end" ) {
            radical_atomic_start := false
        }
        if( line && SubStr(line, 1, 1) != ";" )
        {
            arr := StrSplit(line, " ")
            ime_radicals_pinyin[arr[1]] := arr[2]
            if( radical_atomic_start )
            {
                ime_radical_atomic .= arr[1]
            }
        }
    }
    Assert(ime_radicals_pinyin.Count() != 0)
}

;*******************************************************************************
; "里" -> [["田", "土"], ["甲", "二"]]
RadicalWordSplit(single_word)
{
    global ime_radical_table
    ; Assert(ime_radical_table.HasKey(single_word), single_word)
    return ime_radical_table[single_word]
}

RadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
    Assert(single_radical != "")
    Assert(ime_radicals_pinyin.HasKey(single_radical), "Miss pinyin for """ single_radical "," Asc(single_radical) """" )
    return ime_radicals_pinyin[single_radical]
}

; Atomic radical should no continue split
RadicalIsAtomic(single_word)
{
    global ime_radical_atomic
    return InStr(ime_radical_atomic, single_word)
}

;*******************************************************************************
IsVerb(word)
{
    static verb_string := "串临举乃乘习买争亏亟交享亮亲付令仰伏伐会伛伤伴伸住作佯使例供侦侧侵促保俨修俯倒候借倡偎做停偷偿像允充免兑兜入关兴具养兼冒写冲决冻准凉减凑凝凸出击凿分切划列删刨刮到刺刻剃剐剜剥剩剪割剿劁劈劝办加动助劫勒勾匀包匍卖占卧印即卸压厌厮去发取受变叠叨叩叫召可叱叵吃吆合吐吓吞吟吣吩含听吮启吵吸吹吻吼呆呈告呕呛呲呷呻咀咂咆咒咧咬咳咽品哄哆哏哑哭哼唠售唱啃啄啸啼喂善喊喑喘喜喧喷嗍嗑嗔嗟嗫嘀嘬嘱嘲噘噙嚷嚼囔回囤困围坐坚坠坨垂垄垒垛垦垮埋培堆堕堵塌塞填增墩壮备复夸夺奉奋奏如妄妒姓娶媲媾嫁嫉嫌嫖嬗孀存孵守安完定宠审宰害寄导射尝尥尽居展属屹崛崩崴嵌希带帮干应废建开弄弓引弥弯弹归彷征待徘徜忌忍忏忖忘忙忧念怀怄怕怜急怨怪恋恨恪悟悬惊惑惦惧惩惯想惹愁愚感愣愤愿慰憎憬懂懊戗截戳戴扎扑扒打扔托扣执扩扫扭扮扯扰扳扶找承抄抒抓抗折抟抠抡抢抨披抬抱抹抻抽拄担拆拈拉拌拍拎拒拔拖招拜拟拣拥拦拧拨择括拯拱拴拼拽拾拿持挂挑挖挛挟挠挣挤挥挨挫振挽捂捅捆捉捋捍捎捏捐捕捞捡捣捧捶捺掀掂掌掐排掖掘掠探掣接控推掩掬掭掰掴掷掸揉揍揎描提插握揣揩揪揽搁搂搅搋搏搓搔搛搞搠搡搬搭携搽摁摆摇摈摊摒摔摘摞摧摸摹撂撅撑撒撕撞撤撩播撮撺撼擀擂操擎擒擤擦攀攉攥攮收改攻放救教敞敢散敬敲整敷料斜斟斡斩断无昏映昧是显晃晒晕晴有服望术杀杂来松构染柔查树栖栽框梗械梳棰横欠欢歃歇歧歪死歼殆殉殒殴毁毕毙求汆汹沉沏没沤治泅泛泡注泻泼洇洒洗派浇浞浮浸涂消涉涌涝涣润涨涮涵淌淘淤混淹添渍渗渡渲游湮溃溅溜滑滗滚滥滴漂漆漉漏演漕漤漱潜潲潴濒灌灭炒炖炝炫炼烀烂烤烦烧烫烹焉焊焐焖焙焚焯煅煎煞煨煮煲煸煺煽熄熏熘熨熬爆爬爱牵牺犒犯狙狞独猜献率玩环琢甩申留疏疯疼痊瘫瘸登皈皱盖盛盯相盼看眍眩眬眯眺睁睃睡睬睹瞅瞌瞎瞒瞟瞥瞧瞩瞪瞭矇矗知砍砘砣破砸砻硌碍碰碾磕磨示祈祛祝祭禀禁离秉租积称移窒窝窥窨立竖站竣端笑符笺筑答筛筹签箍算籴粘粜糅糟系繁练织绊绕绗绘络统绣继续绱绲维绷绾缀缉缒缓编缝缠缩缫缭缮缲缴缺罢罩置罱羞羡翕翘翱翻考耍耗耠耪耷耽聆聊联聘聚肄肯育背胜能脱腆腌腻膨臆致舀舂舍舔舞芟花苫荏荒荟荡荼获萃萌萎萦落蒙蒸蔑蔓蔫蔽蕴薅薰蘸蛀蛰蜇蜚蜿螫蠕衍衔补表袒袢袭裂装裱裹褒褪襻要覆见觅览觉觊觐觑觞解触誉譬订认讥讨让讪讲讴讶讹讽设访评诅识诈译诓试诘诛诠询诣诫误诱说请读诽调谄谅谈谋谓谙谛谢谩谱谴豁负败贩贪贬购贮贴贷费贻贿赁赈赊赋赎赏赐赔赚赞赠赢赦走赴赶起趁趄超趔趿跃跌跑跨跪跳践跷跺跻踅踉踌踏踟踢踮踱踹蹁蹂蹉蹋蹒蹦蹬蹭蹲蹿躁躬躲躺轧转轰载辐输辖辗辞辟辨达迁迂迈迎返进迫迷追退送适逃透递逗通逛逝造逼遇遍遏遐遛遨遭遮遴避邀邂配酗酝醉醒采錾鏖钉钓钻铐铡铰铲铺销锁锄错锛锩锪锯锻镂镶闩闪闭闯闷闹闻阅阐防阻附降限陪陷随隔需震露靠鞔鞣顶顾颁颂预领颠颤飘飙飚食饧饯饰饶饿馈驮驱驳驶驻驾骂验骑骖骗骚骟魇鸣黜黩鼓龇"
    return InStr(verb_string, word)
}

IsMeasure(word)
{
    static measure_string := "甲乙丙丁戊己庚辛壬癸子丑寅卯辰巳午未申酉戌亥一二三四五六七八九十百千万亿壹貳貮叁參叄肆伍陸柒捌玖拾佰仟萬億"
    return InStr(measure_string, word)
}

;*******************************************************************************
;
RadicalMatchFirstPart(test_word, ByRef test_radical, ByRef remain_radicals)
{
    local
    if( !test_word ){
        return true
    }

    test_pinyin := RadicalGetPinyin(test_word)
    if( test_pinyin == SubStr(test_radical, 1, 1) ) {
        test_radical := SubStr(test_radical, 2)
        return true
    }
    if( test_pinyin == SubStr(test_radical, 0, 1) ) {
        test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
        return true
    }
    if( RadicalIsAtomic(test_word) ){
        return false
    }

    ; Backup
    test_radical_backup := test_radical
    remain_radicals_backup := CopyObj(remain_radicals)

    radical_word_list := RadicalWordSplit(test_word)
    loop, % radical_word_list.Length()
    {
        loop_radical_index := A_Index
        first_word := radical_word_list[loop_radical_index, 1]
        Assert(first_word != test_word, test_word, true)

        test_radical := test_radical_backup
        remain_radicals := CopyObj(remain_radicals_backup)

        loop, % radical_word_list[loop_radical_index].Length()-1
        {
            remain_radicals[remain_radicals.Length()+A_Index] := radical_word_list[loop_radical_index, A_Index+1]
        }

        if( RadicalMatchFirstPart(first_word, test_radical, remain_radicals) )
        {
            return true
        }
    }

    return false
}

RadicalMatchLastPart(test_word, ByRef test_radical)
{
    if( !test_word ){
        return true
    }

    test_pinyin := RadicalGetPinyin(test_word)
    if( test_pinyin == SubStr(test_radical, 0, 1) ) {
        test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
        return true
    }
    if( test_pinyin == SubStr(test_radical, 1, 1) ) {
        test_radical := SubStr(test_radical, 2)
        return true
    }
    if( RadicalIsAtomic(test_word) ){
        return false
    }

    radical_word_list := RadicalWordSplit(test_word)
    if( radical_word_list.Length() > 0 ) {
        last_word := radical_word_list[1, radical_word_list[1].Length()]
        ; "qianDR" "qianDT" -> 潜
        Assert(last_word != test_word, test_word, true)
        return RadicalMatchLastPart(last_word, test_radical)
    } else {
        return false
    }
}

;*******************************************************************************
; return
;   0 == no match
;   1 == full match
;   2 == part match
RadicalIsFullMatchList(test_word, test_radical, radical_word_list)
{
    local
    match_last_part := false
    loop
    {
        if( radical_word_list.Length() == 0 && test_radical == "" ){
            return 1
        }
        if( test_radical == "" ){
            return 2
        }
        if( radical_word_list.Length() == 0 ){
            return false
        }

        match_any_part := false

        ; Check if is part of first char
        ; e.g. 干 -> 二 丨, "一" H and "二" E both think match
        if( !match_any_part )
        {
            first_word := radical_word_list[1]
            remain_radicals := []
            if( RadicalMatchFirstPart(first_word, test_radical, remain_radicals) )
            {
                radical_word_list.RemoveAt(1)
                loop, % remain_radicals.Length()
                {
                    radical_word_list.InsertAt(1, remain_radicals[A_Index])
                }
                match_any_part := true
            }
        }

        ; e.g. 肉 -> 冂 仌, "人" R will also be match
        if( !match_any_part && !match_last_part )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            if( RadicalMatchLastPart(last_word, test_radical) )
            {
                radical_word_list.RemoveAt(radical_word_list.Length())
                match_any_part := true
                ; match_last_part := true
            }
        }

        if( !match_any_part )
        {
            return 0
        }
    }
}

RadicalCheckWordClass(test_word, test_radical)
{
    if( InStr(test_radical, "!") && !IsVerb(test_word) ){
        return false
    }
    if( InStr(test_radical, "#") && !IsMeasure(test_word)){
        return false
    }
    return true
}

RadicalIsFullMatch(test_word, test_radical)
{
    if( !RadicalCheckWordClass(test_word, test_radical) ){
        return 0
    }
    ; You also need to update `GetRadical`
    test_radical := RegExReplace(test_radical, "[!@#$%^&]")

    radical_word_list := CopyObj(RadicalWordSplit(test_word))
    if( !radical_word_list ){
        return 2
    }
    part_match := false
    for index, element in radical_word_list
    {
        result := RadicalIsFullMatchList(test_word, test_radical, element)
        if( result == 1 ){
            return 1
        }
        if( result == 2 ){
            part_match := true
        }
    }
    if( part_match ) {
        return 2
    } else {
        return 0
    }
}

;*******************************************************************************
; radical_list: ["SS", "YZ", "RE"]
TranslatorResultListFilterByRadical(ByRef translate_result_list, radical_list)
{
    local

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

        index := 1
        loop % translate_result_list.Length()
        {
            translate_result := translate_result_list[index]
            ImeProfilerBegin(36)
            word_value := TranslatorResultGetWord(translate_result)
            should_remove := false
            is_full_match := true
            ; loop each character of "我爱你"
            loop % TranslatorResultGetWordLength(translate_result)
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    result := RadicalIsFullMatch(test_word, test_radical)
                    if( result == 0 ) {
                        should_remove := true
                    }
                    if( result != 1 ) {
                        is_full_match := false
                    }
                }
                if( should_remove ){
                    break
                }
            }

            ; Turn off full match feature
            ; is_full_match := false
            if( is_full_match ) {
                translate_full_match_result_list.Push(translate_result)
            }

            if( should_remove || is_full_match ) {
                translate_result_list.RemoveAt(index)
            } else {
                index += 1
            }

            ImeProfilerEnd(36)
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "

        ; Show full match word first
        loop, % translate_full_match_result_list.Length()
        {
            translate_result_list.InsertAt(A_Index, translate_full_match_result_list[A_Index])
        }

        if( translate_result_list.Length() == 0 )
        {
            translate_result_list.Push(TranslatorResultMakeError())
        }
    }
}
