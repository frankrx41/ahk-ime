import os
import sqlite3

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
db_path = os.path.join(BASE_DIR, "../data/dictionary_tone.db")
file_path = os.path.join(BASE_DIR, "../data/dictonary_long_pinyin.asm")

sqldb = sqlite3.connect(db_path)
cursor = sqldb.cursor()

cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
cursor.execute("SELECT key FROM pinyin WHERE LENGTH(value) >= 6;")
# cursor.execute("SELECT key FROM pinyin WHERE LENGTH(value) >= 6 LIMIT 2;")

source_file = open(file_path, 'w')

print(
"; Store pinyin in db that LENGTH(value) >= 6\n; LENGTH(value) >= 6\n; Generate by " + os.path.basename(__file__) , file=source_file
)

results = cursor.fetchall() # get all the results as a list of tuples
pinyin_list = {}
index = 1
for result in results:
    key = result[0]
    if key and not key in pinyin_list:
        # print(str(index) + "\t" + key, file=source_file)
        print(key, file=source_file)
        index += 1
        pinyin_list[key] = 1

source_file.close()