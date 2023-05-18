;*******************************************************************************
; Radical
;
RadicalInitialize()
{
    local
    global ime_radical_table    := {}
    global ime_radicals_pinyin  := {}
    global ime_radical_atomic   := "一丨丿乀丶𠄌乁乛㇕乙𠃊乚亅㇆勹㇉𠃋匚匸冂凵⺆巜丄丅龴厶艹冖罓宀罒㓁癶覀𤇾𦥯龷皿亻彳阝牜衤飠纟犭丩丬礻讠訁扌忄饣釒钅爿豸刂卩卪厂广耂虍疒⺈弋廴辶㔾𠂔疋肀𠔉𠤏𡿺叵囙夨夬屮丱彑𠂢旡歺辵尢夂匕刀儿几力人入又川寸大飞工弓己已巾口囗马门女山尸士巳兀夕小幺子贝长车斗方风父戈户戸戶火见斤毛木牛片气日氏手殳水瓦王韦文毋心牙曰月支止爪白甘瓜禾立龙矛母目鸟皮生石矢示田玄业臣虫而耳缶艮臼米齐肉色舌页先血羊聿至舟竹⺮自羽貝采釆镸車辰赤豆谷見角克里卤麦身豕辛言邑酉酋走足靑雨齿非金隶鱼鬼韭面首韋頁龹𠂉用电乃为了九万丁个丫不上下"

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

    Loop, Parse, file_content, `n, `r
    {
        line := A_LoopField
        if( line && SubStr(line, 1, 1) != ";" )
        {
            arr := StrSplit(line, " ")
            ime_radicals_pinyin[arr[1]] := arr[2]
        }
    }
    Assert(ime_radicals_pinyin.Count() != 0)

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

RadicalCheckPinyin(radical, test_pinyin)
{
    local
    radical_pinyin := RadicalGetPinyin(radical)
    if( radical_pinyin == test_pinyin ){
        return true
    }
    if( InStr("匚匸冂凵⺆", radical) && test_pinyin == "O" ){
        return true
    }
    if( InStr("乁乛㇕乙𠃊乚亅㇆勹㇉𠃋巜丄丅龴厶巛卄廾丌彐卅卝攵卌幵", radical) && test_pinyin == "V" ){
        return true
    }
    if( radical == "广" && test_pinyin == "C" ){
        return true
    }
    if( radical == "丿" && test_pinyin == "D" ){
        return true
    }

    return false
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

IsFirstName(word)
{
    ; https://zh.wikipedia.org/zh-cn/%E7%99%BE%E5%AE%B6%E5%A7%93
    static first_name_string := "赵钱孙李周吴郑王冯陈褚卫蒋沈韩杨朱秦尤许何吕施张孔曹严华金魏陶姜戚谢邹喻柏水窦章云苏潘葛奚范彭郎鲁韦昌马苗凤花方俞任袁柳酆鲍史唐费廉岑薛雷贺倪汤滕殷罗毕郝邬安常乐于时傅皮卞齐康伍余元卜顾孟平黄和穆萧尹姚邵湛汪祁毛禹狄米贝明臧计伏成戴谈宋茅庞熊纪舒屈项祝董梁杜阮蓝闵席季麻强贾路娄危江童颜郭梅盛林刁锺徐邱骆高夏蔡田樊胡凌霍虞万支柯昝管卢莫经房裘缪干解应宗丁宣贲邓郁单杭洪包诸左石崔吉钮龚程嵇邢滑裴陆荣翁荀羊於惠甄麹家封芮羿储靳汲邴糜松井段富巫乌焦巴弓牧隗山谷车侯宓蓬全郗班仰秋仲伊宫甯仇栾暴甘钭厉戎祖武符刘景詹束龙叶幸司韶郜黎蓟薄印宿白怀蒲邰从鄂索咸籍赖卓蔺屠蒙池乔阴鬱胥能苍双闻莘党翟谭贡劳逄姬申扶堵冉宰郦雍郤璩桑桂濮牛寿通边扈燕冀郏浦尚农温别庄晏柴瞿阎充慕连茹习宦艾鱼容向古易慎戈廖庾终暨居衡步都耿满弘匡国文寇广禄阙东欧殳沃利蔚越夔隆师巩厍聂晁勾敖融冷訾辛阚那简饶空曾毋沙乜养鞠须丰巢关蒯相查后荆红游竺权逯盖益桓公俟上官阳人赫皇甫尉迟澹台冶政淳太叔轩辕令狐离宇长鲜闾丘徒亓仉督子颛端木西漆雕正壤驷良拓跋夹父穀晋楚闫法汝鄢涂钦百里南门呼延归海舌微生岳帅缑亢况後有琴商牟佘佴伯赏墨哈谯笪年爱佟第五言福姓"
    return InStr(first_name_string, word)
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
        loop, % radical_word_list.Length()
        {
            first_word := radical_word_list[A_Index, 1]
            if( RadicalCheckPinyin(first_word, SubStr(test_radical, 1, 1)) || RadicalCheckPinyin(first_word, SubStr(test_radical, 0, 1)) ){
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
        if( RadicalCheckPinyin(test_word, SubStr(test_radical, 0, 1)) ) {
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
        Assert(first_word != test_word, test_word, true)

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

RadicalMatchLastPart(test_word, ByRef test_radical)
{
    if( !test_word ){
        return true
    }

    if( RadicalCheckPinyin(test_word, SubStr(test_radical, 0, 1)) ) {
        test_radical := SubStr(test_radical, 1, StrLen(test_radical)-1)
        return true
    }
    if( RadicalCheckPinyin(test_word, SubStr(test_radical, 1, 1)) ) {
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
            if( RadicalMatchLastPart(last_word, test_radical) )
            {
                radical_word_list.RemoveAt(radical_word_list.Length())
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
    if( InStr(test_radical, "#") && !IsMeasure(test_word)){
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
            ImeProfilerBegin(36)
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
                TranslatorResultAppendComment(translate_result, "1")
                translate_full_match_result_list.Push(translate_result)
            }
            if( match_level == radical_match_level_last_match ) {
                TranslatorResultAppendComment(translate_result, "2")
                translate_last_match_result_list.Push(translate_result)
            }
            if( match_level == radical_match_level_no_radical ) {
                TranslatorResultAppendComment(translate_result, "3")
                translate_no_radical_result_list.Push(translate_result)
            }

            if( match_level != radical_match_level_part_match ) {
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
            ; translate_full_match_result_list[A_Index, 4] := 1
            translate_result_list.InsertAt(A_Index, translate_full_match_result_list[A_Index])
        }
        loop, % translate_last_match_result_list.Length()
        {
            ; translate_last_match_result_list[A_Index, 4] := 2
            translate_result_list.Push(translate_last_match_result_list[A_Index])
        }
        loop, % translate_no_radical_result_list.Length()
        {
            ; translate_no_radical_result_list[A_Index, 4] := 3
            translate_result_list.Push(translate_no_radical_result_list[A_Index])
        }

        if( translate_result_list.Length() == 0 )
        {
            translate_result_list.Push(TranslatorResultMakeError())
        }
    }
}
