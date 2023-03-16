from pypinyin import pinyin, lazy_pinyin, Style
import os
import jieba
# jieba.initialize()

from pypinyin_dict.phrase_pinyin_data import cc_cedict
cc_cedict.load()
from pypinyin_dict.pinyin_data import kxhc1983
kxhc1983.load()

absolute_path = os.path.dirname(__file__)

# input
relative_path = "../data/dictionary.csv"
full_path = os.path.join(absolute_path, relative_path)
f1 = open(full_path, "r")

# output
relative_path = "../data/dictionary_tone.csv"
full_path = os.path.join(absolute_path, relative_path)
f2 = open(full_path, "w")

# error recoder
relative_path = "../data/dictionary_error_heteronym_words.csv"
full_path = os.path.join(absolute_path, relative_path)
f3 = open(full_path, "w")

relative_path = "../data/dictionary_error_single_word.json"
full_path = os.path.join(absolute_path, relative_path)
f4 = open(full_path, "w")

check_single_word: dict[str, list[str]] = {}


def process(in_str: str):
    # z,zhang,长,22287
    # split line by ","
    line = in_str.split(",")
    word = line[2]
    weight = int(line[3])

    full_pinyin_str = ""
    sim_pinyin_str = ""
    check_pinyin = ""

    if len(word) == 1:
        full_pinyin = pinyin(word, style=Style.TONE3, heteronym=True, neutral_tone_with_five=True)[0]
        # check heteronym
        if len(full_pinyin) > 1 and word not in check_single_word:
            check_single_word[word] = []
            for pin_str in full_pinyin:
                check_single_word[word].append(pin_str)

        for pin_str in full_pinyin:
            full_pinyin_str = pin_str
            sim_pinyin_str = pin_str[:1] + pin_str[-1]
            check_pinyin = pin_str[:-1]

            if check_pinyin == line[1]:
                result = sim_pinyin_str + "," + full_pinyin_str + "," + word + "," + str(weight)
                f2.write(result + "\n")
                if word in check_single_word:
                    check_single_word[word].remove(pin_str)
                    if len(check_single_word[word]) == 0:
                        del check_single_word[word]
    else:
        # full_pinyin = pinyin(word, style=Style.TONE3, heteronym=False, neutral_tone_with_five=True)
        # full_pinyin = lazy_pinyin(word, style=Style.TONE3, tone_sandhi=True, neutral_tone_with_five=True)
        # word = word.replace("谁", "shei2")
        # word = word.replace("虐", "nve4")
        
        full_pinyin = lazy_pinyin(list(jieba.cut(word)), style=Style.TONE3, neutral_tone_with_five=True)
        # full_pinyin = full_pinyin[0]

        for pin_str in full_pinyin:
            pin_str = pin_str.replace("ve", "ue")
            full_pinyin_str += pin_str
            sim_pinyin_str += pin_str[:1] + pin_str[-1]
            check_pinyin += pin_str[0:-1] + "'"

        pinyin_error = False
        check_pinyin = check_pinyin[:-1]
        if check_pinyin != line[1]:
            pinyin_error = True

        if not pinyin_error:
            result = sim_pinyin_str + "," + full_pinyin_str + "," + word + "," + str(weight)
            f2.write(result + "\n")
        else:
            f3.write(in_str + str(full_pinyin) + "\n")
    pass

debug_script = False
# debug_script = True

if debug_script:
    process("a's,ai'shei,爱谁,24926")
    process("c'b,chang'bang,长棒,1")
    process("b'n,bao'nue,暴虐,26057")
    process("a'a,a'a,啊啊,25294")
    process("a,a,啊,26302")
    process("n'h,ni'hao,你好,27000")
    process("z,zhang,长,22287")
    process("c,chang,长,22287")
    process("z,zhong,中,26936")
    process("j,jian,键,25536")
    process("y'd'j,yin'dao'jian,引导键,32875")
    process("c'y,chang'yuan,长圆,23979")
    # print(check_single_word)
else:
    # read file line by line
    index = 1
    for line in f1:
        line = line.strip()
        process(line)

        # index += 1
        # if index >= 5000:
        #     break

if len(check_single_word) > 0:
    f4.write(str(check_single_word))
exit(0)
