from pypinyin import pinyin, lazy_pinyin, Style
import os

absolute_path = os.path.dirname(__file__)

# open file "../data/character-split-duplicate.txt"
relative_path = "../data/character-split-duplicate.txt"
full_path = os.path.join(absolute_path, relative_path)
f1 = open(full_path, "r")

# open file output.txt
relative_path = "../data/character-split-pinyin.txt"
full_path = os.path.join(absolute_path, relative_path)
f2 = open(full_path, "w")

# read file line by line
index = 1
for line in f1:
    # split line by ","
    result = ""
    for character in pinyin(line[0], style=Style.FIRST_LETTER):
        result += character[0].upper()

    if result == line[0]:
        continue
    # print(line[0], pinyin)
    # if index >= 10:
    # break
    # index += 1

    # write result into f2
    f2.write(line[0] + "" + result + "\n")
