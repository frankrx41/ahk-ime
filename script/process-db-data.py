from pypinyin import pinyin, lazy_pinyin, Style
import os
import jieba
# jieba.initialize()

absolute_path = os.path.dirname(__file__)

relative_path = "../data/ciku.csv"
full_path = os.path.join(absolute_path, relative_path)
f1 = open(full_path, "r")

relative_path = "../data/ciku_output.csv"
full_path = os.path.join(absolute_path, relative_path)
f2 = open(full_path, "w")

relative_path = "../data/ciku_heteronym.csv"
full_path = os.path.join(absolute_path, relative_path)
f3 = open(full_path, "w")

relative_path = "../data/ciku_heteronym_single.csv"
full_path = os.path.join(absolute_path, relative_path)
f4 = open(full_path, "w")

def process(in_str: str):
    # split line by ","
    line = in_str.split(",")
    word = line[2]
    weight = int(line[3])

    full_pinyin_str = ""
    sim_pinyin_str = ""
    test_pinyin = ""

    if len(word) == 1:
        full_pinyin = pinyin(word, style=Style.TONE3, heteronym=True, neutral_tone_with_five=True)
        full_pinyin = full_pinyin[0]
        for pin in full_pinyin:

            pin_str = pin
            full_pinyin_str = pin_str
            sim_pinyin_str = pin_str[:1] + pin_str[-1]
            test_pinyin = pin_str[:-1]

            if test_pinyin == line[1]:
                result = sim_pinyin_str + "," + full_pinyin_str + "," + word + "," + str(weight)
                f2.write(result + "\n")
            else:
                f4.write(in_str + " [" + str(pin_str) + "]\n")
    else:
        # full_pinyin = pinyin(word, style=Style.TONE3, heteronym=False, neutral_tone_with_five=True)
        # full_pinyin = lazy_pinyin(word, style=Style.TONE3, tone_sandhi=True, neutral_tone_with_five=True)
        full_pinyin = lazy_pinyin(list(jieba.cut(word)), style=Style.TONE3, tone_sandhi=True, neutral_tone_with_five=True)

        for pin in full_pinyin:
            pin_str = pin
            full_pinyin_str += pin_str
            sim_pinyin_str += pin_str[:1] + pin_str[-1]
            test_pinyin += pin_str[0:-1] + "'"

        pinyin_error = False
        test_pinyin = test_pinyin[:-1]
        if test_pinyin != line[1]:
            pinyin_error = True

        if not pinyin_error:
            result = sim_pinyin_str + "," + full_pinyin_str + "," + word + "," + str(weight)
            f2.write(result + "\n")
        else:
            f3.write(in_str + str(full_pinyin) + "\n")
    pass

# process("a'a,a'a,啊啊,25294")
# process("a,a,啊,26302")
# process("n'h,ni'hao,你好,27000")
# process("z,zhang,长,22287")
# process("c,chang,长,22287")
# process("z,zhong,中,26936")
# process("j,jian,键,25536")
# process("y'd'j,yin'dao'jian,引导键,32875")
# process("c'y,chang'yuan,长圆,23979")


# exit(0)

# read file line by line
index = 1
for line in f1:
    line = line.strip()
    process(line)

    # index += 1
    # if index >= 5000:
    #     break
