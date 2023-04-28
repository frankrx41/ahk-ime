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
    radical_atomic_start := false
    Loop, Parse, file_content, `n, `r
    {
        line := A_LoopField
        if( line == "#radical_atomic_start" ) {
            radical_atomic_start := true
        }
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
    return ime_radical_table[single_word]
}

RadicalGetPinyin(single_radical)
{
    local
    global ime_radicals_pinyin
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
    verb_string := "串临举乃乘习买争亏亟交享亮亲付令仰伏伐会伛伤伴伸住作佯使例供侦侧侵促保俨修俯倒候借倡偎做停偷偿像允充免兑兜入关兴具养兼冒写冲决冻准凉减凑凝凸出击凿分切划列删刨刮到刺刻剃剐剜剥剩剪割剿劁劈劝办加动助劫勒勾匀包匍卖占卧印即卸压厌厮去发取受变叠叨叩叫召可叱叵吃吆合吐吓吞吟吣吩含听吮启吵吸吹吻吼呆呈告呕呛呲呷呻咀咂咆咒咧咬咳咽品哄哆哏哑哭哼唠售唱啃啄啸啼喂善喊喑喘喜喧喷嗍嗑嗔嗟嗫嘀嘬嘱嘲噘噙嚷嚼囔回囤困围坐坚坠坨垂垄垒垛垦垮埋培堆堕堵塌塞填增墩壮备复夸夺奉奋奏如妄妒姓娶媲媾嫁嫉嫌嫖嬗孀存孵守安完定宠审宰害寄导射尝尥尽居展属屹崛崩崴嵌希带帮干应废建开弄弓引弥弯弹归彷征待徘徜忌忍忏忖忘忙忧念怀怄怕怜急怨怪恋恨恪悟悬惊惑惦惧惩惯想惹愁愚感愣愤愿慰憎憬懂懊戗截戳戴扎扑扒打扔托扣执扩扫扭扮扯扰扳扶找承抄抒抓抗折抟抠抡抢抨披抬抱抹抻抽拄担拆拈拉拌拍拎拒拔拖招拜拟拣拥拦拧拨择括拯拱拴拼拽拾拿持挂挑挖挛挟挠挣挤挥挨挫振挽捂捅捆捉捋捍捎捏捐捕捞捡捣捧捶捺掀掂掌掐排掖掘掠探掣接控推掩掬掭掰掴掷掸揉揍揎描提插握揣揩揪揽搁搂搅搋搏搓搔搛搞搠搡搬搭携搽摁摆摇摈摊摒摔摘摞摧摸摹撂撅撑撒撕撞撤撩播撮撺撼擀擂操擎擒擤擦攀攉攥攮收改攻放救教敞敢散敬敲整敷料斜斟斡斩断无昏映昧是显晃晒晕晴有服望术杀杂来松构染柔查树栖栽框梗械梳棰横欠欢歃歇歧歪死歼殆殉殒殴毁毕毙求汆汹沉沏没沤治泅泛泡注泻泼洇洒洗派浇浞浮浸涂消涉涌涝涣润涨涮涵淌淘淤混淹添渍渗渡渲游湮溃溅溜滑滗滚滥滴漂漆漉漏演漕漤漱潜潲潴濒灌灭炒炖炝炫炼烀烂烤烦烧烫烹焉焊焐焖焙焚焯煅煎煞煨煮煲煸煺煽熄熏熘熨熬爆爬爱牵牺犒犯狙狞独猜献率玩环琢甩申留疏疯疼痊瘫瘸登皈皱盖盛盯相盼看眍眩眬眯眺睁睃睡睬睹瞅瞌瞎瞒瞟瞥瞧瞩瞪瞭矇矗知砍砘砣破砸砻硌碍碰碾磕磨示祈祛祝祭禀禁离秉租积称移窒窝窥窨立竖站竣端笑符笺筑答筛筹签箍算籴粘粜糅糟系繁练织绊绕绗绘络统绣继续绱绲维绷绾缀缉缒缓编缝缠缩缫缭缮缲缴缺罢罩置罱羞羡翕翘翱翻考耍耗耠耪耷耽聆聊联聘聚肄肯育背胜能脱腆腌腻膨臆致舀舂舍舔舞芟花苫荏荒荟荡荼获萃萌萎萦落蒙蒸蔑蔓蔫蔽蕴薅薰蘸蛀蛰蜇蜚蜿螫蠕衍衔补表袒袢袭裂装裱裹褒褪襻要覆见觅览觉觊觐觑觞解触誉譬订认讥讨让讪讲讴讶讹讽设访评诅识诈译诓试诘诛诠询诣诫误诱说请读诽调谄谅谈谋谓谙谛谢谩谱谴豁负败贩贪贬购贮贴贷费贻贿赁赈赊赋赎赏赐赔赚赞赠赢赦走赴赶起趁趄超趔趿跃跌跑跨跪跳践跷跺跻踅踉踌踏踟踢踮踱踹蹁蹂蹉蹋蹒蹦蹬蹭蹲蹿躁躬躲躺轧转轰载辐输辖辗辞辟辨达迁迂迈迎返进迫迷追退送适逃透递逗通逛逝造逼遇遍遏遐遛遨遭遮遴避邀邂配酗酝醉醒采錾鏖钉钓钻铐铡铰铲铺销锁锄错锛锩锪锯锻镂镶闩闪闭闯闷闹闻阅阐防阻附降限陪陷随隔需震露靠鞔鞣顶顾颁颂预领颠颤飘飙飚食饧饯饰饶饿馈驮驱驳驶驻驾骂验骑骖骗骚骟魇鸣黜黩鼓龇"
    return InStr(verb_string, word)
}

;*******************************************************************************
;
RadicalMatchFirstPart(test_word, ByRef test_radical, ByRef remain_radicals)
{
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

    radical_word_list := RadicalWordSplit(test_word)
    first_word := radical_word_list[1, 1]

    loop, % radical_word_list[1].Length()-1
    {
        remain_radicals[remain_radicals.Length()+A_Index] := radical_word_list[1, A_Index+1]
    }

    Assert(first_word != test_word, test_word, true)
    return RadicalMatchFirstPart(first_word, test_radical, remain_radicals)
}

RadicalMatchLastPart(test_word, ByRef test_radical)
{
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
    last_word := radical_word_list[1, radical_word_list.Length()]

    Assert(last_word != test_word, test_word, true)
    return RadicalMatchLastPart(last_word, test_radical)
}

;*******************************************************************************
;
RadicalIsFullMatchList(test_word, test_radical, radical_word_list)
{
    loop
    {
        if( test_radical == "" ){
            return true
        }
        if( radical_word_list.Length() == 0 || ){
            return false
        }

        has_part_same := false

        ; Check if is part of first char
        ; e.g. 干 -> 二 丨, "一" H and "二" E both think match
        if( !has_part_same )
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
                has_part_same := true
            }
        }

        ; e.g. 肉 -> 冂 仌, "人" R will also be match
        if( !has_part_same )
        {
            last_word := radical_word_list[radical_word_list.Length()]
            if( RadicalMatchLastPart(last_word, test_radical) )
            {
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

RadicalIsFullMatch(test_word, test_radical)
{
    only_verb := false
    if( InStr(test_radical, "!") ){
        test_radical := StrReplace(test_radical, "!")
        only_verb := true
    }

    if( only_verb && !IsVerb(test_word) ){
        return false
    }

    radical_word_list := CopyObj(RadicalWordSplit(test_word))
    for index, element in radical_word_list
    {
        result := RadicalIsFullMatchList(test_word, test_radical, element)
        if( result ){
            return true
        }
    }
    return false
}

;*******************************************************************************
; radical_list: ["SS", "YZ", "RE"]
TranslatorResultFilterByRadical(ByRef translate_result, radical_list)
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
        index := 1
        loop % translate_result.Length()
        {
            ImeProfilerBegin(36)
            word_value := translate_result[index, 2]
            should_remove := false
            ; loop each character of "我爱你"
            loop % translate_result[index, 5]
            {
                test_radical := radical_list[A_Index]
                if( test_radical )
                {
                    test_word := SubStr(word_value, A_Index, 1)
                    if( !RadicalIsFullMatch(test_word, test_radical) )
                    {
                        should_remove := true
                    }
                }
                if( should_remove ){
                    break
                }
            }

            if( should_remove ) {
                translate_result.RemoveAt(index)
            } else {
                index += 1
            }
            ImeProfilerEnd(36)
        }

        ; "Radical: [" radical_list "] " "(" found_result.Length() ") " ; "(" A_TickCount - begin_tick ") "
    }
}
