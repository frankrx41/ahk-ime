;*******************************************************************************
IsVerb(word)
{
    static verb_string := "串临举乃乘习买争亏亟交享亮亲付令仰伏伐会伛伤伴伸住作佯使例供侦侧侵促保俨修俯倒候借倡偎做停偷偿像允充免兑兜入关兴具养兼冒写冲决冻准凉减凑凝凸出击凿分切划列删刨刮到刺刻剃剐剜剥剩剪割剿劁劈劝办加动助劫勒勾匀包匍卖占卧印即卸压厌厮去发取受变叠叨叩叫召可叱叵吃吆合吐吓吞吟吣吩含听吮启吵吸吹吻吼呆呈告呕呛呲呷呻咀咂咆咒咧咬咳咽品哄哆哏哑哭哼唠售唱啃啄啸啼喂善喊喑喘喜喧喷嗍嗑嗔嗟嗫嘀嘬嘱嘲噘噙嚷嚼囔回囤困围坐坚坠坨垂垄垒垛垦垮埋培堆堕堵塌塞填增墩壮备复夸夺奉奋奏如妄妒姓娶媲媾嫁嫉嫌嫖嬗孀存孵守安完定宠审宰害寄导射尝尥尽居展属屹崛崩崴嵌希带帮干应废建开弄弓引弥弯弹归彷征待徘徜忌忍忏忖忘忙忧念怀怄怕怜急怨怪恋恨恪悟悬惊惑惦惧惩惯想惹愁感愣愤愿慰憎憬懂懊戗截戳戴扎扑扒打扔托扣执扩扫扭扮扯扰扳扶找承抄抒抓抗折抟抠抡抢抨披抬抱抹抻抽拄担拆拈拉拌拍拎拒拔拖招拜拟拣拥拦拧拨择括拯拱拴拼拽拾拿持挂挑挖挛挟挠挣挤挥挨挫振挽捂捅捆捉捋捍捎捏捐捕捞捡捣捧捶捺掀掂掌掐排掖掘掠探掣接控推掩掬掭掰掴掷掸揉揍揎描提插握揣揩揪揽搁搂搅搋搏搓搔搛搞搠搡搬搭携搽摁摆摇摈摊摒摔摘摞摧摸摹撂撅撑撒撕撞撤撩播撮撺撼擀擂操擎擒擤擦攀攉攥攮收改攻放救教敞敢散敬敲整敷料斜斟斡斩断无昏映昧是显晃晒晕晴有服望术杀杂来松构染柔查树栖栽框梗械梳棰横欠欢歃歇歧歪死歼殆殉殒殴毁毕毙求汆汹沉沏没沤治泅泛泡注泻泼洇洒洗派浇浞浮浸涂消涉涌涝涣润涨涮涵淌淘淤混淹添渍渗渡渲游湮溃溅溜滑滗滚滥滴漂漆漉漏演漕漤漱潜潲潴濒灌灭炒炖炝炫炼烀烂烤烦烧烫烹焉焊焐焖焙焚焯煅煎煞煨煮煲煸煺煽熄熏熘熨熬爆爬爱牵牺犒犯狙狞独猜献率玩环琢甩申留疏疯疼痊瘫瘸登皈皱盖盛盯相盼看眍眩眬眯眺睁睃睡睬睹瞅瞌瞎瞒瞟瞥瞧瞩瞪瞭矇矗知砍砘砣破砸砻硌碍碰碾磕磨示祈祛祝祭禀禁离秉租积称移窒窝窥窨立竖站竣端笑符笺筑答筛筹签箍算籴粘粜糅糟系繁练织绊绕绗绘络统绣继续绱绲维绷绾缀缉缒缓编缝缠缩缫缭缮缲缴缺罢罩置罱羞羡翕翘翱翻考耍耗耠耪耷耽聆聊联聘聚肄肯育背生胜能脱腆腌腻膨臆致舀舂舍舔舞芟花苫荏荒荟荡荼获萃萌萎萦落蒙蒸蔑蔓蔫蔽蕴薅薰蘸蛀蛰蜇蜚蜿螫蠕衍衔补表袒袢袭裂装裱裹褒褪襻要覆见觅览觉觊觐觑觞解触誉譬订认讥讨让讪讲讴讶讹讽设访评诅识诈译诓试诘诛诠询诣诫误诱说请读诽调谄谅谈谋谓谙谛谢谩谱谴豁负败贩贪贬购贮贴贷费贻贿赁赈赊赋赎赏赐赔赚赞赠赢赦走赴赶起趁趄超趔趿跃跌跑跨跪跳践跷跺跻踅踉踌踏踟踢踮踱踹蹁蹂蹉蹋蹒蹦蹬蹭蹲蹿躁躬躲躺轧转轰载辐输辗辞辟辨达迁迂迈迎返进迫迷追退送适逃透递逗通逛逝造逼遇遍遏遐遛遨遭遮遴避邀邂配酗酝醉醒采錾鏖钉钓钻铐铡铰铲铺销锁锄错锛锩锪锯锻镂镶闩闪闭闯闷闹闻阅阐防阻附降限陪陷随隔需震露靠鞔鞣顶顾颁颂领颠颤飘飙飚食饧饯饰饶饿馈驮驱驳驶驻驾骂验骑骖骗骚骟魇鸣黜黩鼓龇省"
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

IsLastWord(word)
{
    static interjection_string := "啊吧呀唉唉哇嘖啧唷喲哟呼噫哦嗯吗了的呀声"
    return InStr(interjection_string, word)
}

IsFirstWord(word)
{
    static first_word_string := "我他她它这那人不但还很就老没难旧用新非好去是大小"
    return InStr(first_word_string, word)
}

IsPreposition(word)
{
    static preposition_string := "与为于从以依向和在将当把拿比用给自被让除靠会"
    return InStr(preposition_string, word)
}

IsNumeral(word)
{
    ; https://ja.wikipedia.org/wiki/%E5%8A%A9%E6%95%B0%E8%A9%9E
    static numeral_string := "丁両个人位体俩俵倆個具冊册出刀分切刎前剑剣劍包匹区區卓双反口句只台叶叺合名品喉回基壶壺头家対封尊尾局巻帐帖席帳幅幕年座张張战戦戰戶户戸手把拍挂振挺掛敗斤日时時晩月服本朵机条杯枚果枝架柄柱栋株條棟棹機灯点燈片献獻玉球画番畫畳疋発皿着石票秒筋篇粒組组缽羽脚腰腳腹膳舆艇艘菓葉著行貫貼败贯贴足躯軀軒輪輿轩轮连通連部鉢錠钵锭門门阶階隻雙面頁領頭顆页领颗首騎骑體點齣"
    return InStr(numeral_string, word)
}