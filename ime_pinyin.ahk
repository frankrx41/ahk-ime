IsFullPinyin(initials, vowels)
{
    global zero_initials_table
    global pinyin_table

    return (zero_initials_table.HasKey(initials) && vowels == "") || (pinyin_table[initials, vowels])
}

GetFullVowels(initials, vowels)
{
    global pinyin_table
    return pinyin_table[initials][vowels]
}

GetFullInitials(initials)
{
    global pinyin_table
    return pinyin_table[initials][1]
}

IsInitials(initials)
{
    global pinyin_table
    return pinyin_table.HasKey(initials)
}

PinyinInit()
{
    local
    global JSON
    global pinyin_table

    ; 零声母
    global zero_initials_table := ["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou","n"]

    ; 全拼声母韵母表
    full_spelling_json =
    (LTrim
        {
            "a" :{"1":"a","ai":"i","an":"n","ang":"ng","ao":"o"},
            "e" :{"1":"e","ei":"i","en":"n","eng":"ng","er":"r"},
            "o" :{"1":"o","ou":"u"},
            "i" :{"1":"i"},
            "u" :{"1":"u"},
            "v" :{"1":"v"},

            "b" :{"1":"b","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","u":"u","un":"un"},
            "p" :{"1":"p","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","o":"o","ou":"ou","u":"u"},
            "m" :{"1":"m","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","o":"o","ou":"ou","u":"u"},
            "f" :{"1":"f","a":"a","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","iao":"iao","o":"o","ou":"ou","u":"u"},

            "d" :{"1":"d","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "t" :{"1":"t","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","eng":"eng","ei":"ei","i":"i","ian":"ian","iao":"iao","ie":"ie","ing":"ing","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "n" :{"1":"n","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","uo":"uo","un":"un","ve":"ue"},
            "l" :{"1":"l","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","eng":"eng","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu","ong":"ong","on":"ong","ou":"ou","u":"u","v":"v","uan":"uan","ue":"ue","un":"un","uo":"uo","ve":"ue"},

            "g" :{"1":"g","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "k" :{"1":"k","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","ei":"ei","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "h" :{"1":"h","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},

            "j" :{"1":"j","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"},
            "q" :{"1":"q","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","ue":"ue","un":"un","van":"uan","ve":"ue","vn":"un","v":"u"},
            "x" :{"1":"x","i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iong":"iong","iu":"iu","u":"u","uan":"uan","un":"un","ue":"ue","van":"uan","ve":"ue","vn":"un","v":"u"},

            "zh":{"1":"zh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uang":"uang"},
            "ch":{"1":"ch","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "sh":{"1":"sh","a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ou":"ou","u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"},
            "r" :{"1":"r","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},

            "z" :{"1":"z", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","ei":"ei","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "c" :{"1":"c", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},
            "s" :{"1":"s", "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao","e":"e","en":"en","eng":"eng","i":"i","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"},

            "y" :{"1":"y","a":"a","an":"an","ang":"ang","ao":"ao","e":"e","i":"i","in":"in","ing":"ing","o":"o","ong":"ong","on":"ong","ou":"ou","u":"u","uan":"uan","ue":"ue","un":"un","v":"u","van":"uan","ve":"ue","vn":"un"},
            "w" :{"1":"w","a":"a","ai":"ai","an":"an","ang":"ang","ei":"ei","en":"en","eng":"eng","o":"o","u":"u"}
        }
    )

    pinyin_table := JSON.Load(full_spelling_json)
    pinyin_table["l","ue"] := "ue"
    pinyin_table["n","ue"] := "ue"

    for key,value In zero_initials_table
    {
        if (StrLen(value)>1)
        {
            pinyin_table[t1:=SubStr(value, 1, 1)].Delete(value)
            pinyin_table[t1][t2:=SubStr(value, 2)]:=t2
        }
    }

    PinyinAssistantInitialize()
}
