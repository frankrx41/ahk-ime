import os
import sqlite3


full_pinyin = """
ai ei ao ou er an en
bai bei bao bie ban ben bin banɡ benɡ binɡ
pai pei pao pou pie pan pen pin panɡ penɡ pinɡ
mai mei mao mou miu mie man men min manɡ menɡ minɡ
fei fou fan fen fanɡ fenɡ
dai dei dui dao dou diu die dan den dun danɡ denɡ dinɡ donɡ
tai tui tao tou tie tan tun tanɡ tenɡ tinɡ tonɡ
nai nei nao nou niu nie nve nan nen nin nun nanɡ nenɡ ninɡ nonɡ
lai lei lao lou liu lie lve lan lin lun lanɡ lenɡ linɡ lonɡ
ɡai ɡei ɡui ɡao ɡou ɡan ɡen ɡun ɡanɡ ɡenɡ ɡonɡ
kai kei kui kao kou kan ken kun kanɡ kenɡ konɡ
hai hei hui hao hou han hen hun hanɡ henɡ honɡ
jiu jie jue jin jun jinɡ
qiu qie que qin qun qinɡ
xiu xiu xue xin xun xinɡ
zhai zhei zhui zhao zhou zhan zhen zhun zhanɡ zhenɡ zhonɡ
chai chui chao chou chan chen chun chanɡ chenɡ chonɡ
shai shei shui shao shou shan shen shun shanɡ shenɡ
rui rao rou ran ren run ranɡ renɡ ronɡ
zai zei zui zao zou zan zen zun zanɡ zenɡ zonɡ
cai cui cao cou can cen cun canɡ cenɡ conɡ
sai sui sao sou san sen sun sanɡ senɡ sonɡ
yao you yue yan yin yun yanɡ yinɡ yong
wai wei wan wen wanɡ wenɡ
a o e
ba bo bi bu biao bian
pa po pi pu piao pian
ma mo me mi mu miao mian
fa fo fu fiao
da de di du dia diao dian duo duan
ta te ti tu tiao tian tuo tuan
na ne ni nu nv niao nian nianɡ nuo nuan
la lo le li lu lv lia liao lian lianɡ luo luan
ɡa ɡe ɡu ɡua ɡuo ɡuai ɡuan ɡuanɡ
ka ke ku kua kuo kuai kuan kuanɡ
ha he hu hua huo huai huan huanɡ
ji ju jia jiao jian jianɡ jionɡ juan
qi qu qia qiao qian qianɡ qionɡ quan
xi xu xia xiao xian xianɡ xionɡ xuan
zha zhe zhi zhu zhua zhuo zhuai zhuan zhuanɡ
cha che chi chu chua chuo chuai chuan chuanɡ
sha she shi shu shua shuo shuai shuan shuanɡ
re ri ru rua ruo ruan
za ze zi zu zuo zuan
ca ce ci cu cuo cuan
sa se si su suo suan
ya yo ye yi yu yuan
wa wo wu
"""

# Open db dictionary_tone.db
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(BASE_DIR, "../data/dictionary_tone.db")
sqldb = sqlite3.connect(db_path)
cursor = sqldb.cursor()

# cursor.execute("SELECT value FROM pinyin WHERE key='a4' LIMIT 1")

# print("a4 not found")
# print(cursor.fetchall())


# split `full_pinyin` by spaces
for pinyin in set(full_pinyin.split()):
    # loop 1 to 4
    for i in range(1, 5):
        if len(pinyin) > 2:
            continue
        pin = pinyin + str(i)
        # print()
        # SELECT key,value,weight,comment FROM 'pinyin' WHERE
        cursor.execute("SELECT value FROM pinyin WHERE key='" + pin + "' LIMIT 1")
        if (len(cursor.fetchall()) == 0):
            print(pin)
        # break
    pass
