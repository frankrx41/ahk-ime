IsCompletePinyin(initials, vowels)
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
    global zero_initials_table := {}

    ; 零声母
    zero_initials := ["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou"]

    ; 全拼声母韵母表
    full_spelling_json =
    (LTrim
        {
            "a" :{"1":"a","ai":"i","an":"n","ag":"ng","ang":"ng","ao":"o"},
            "e" :{"1":"e","ei":"i","en":"n","eg":"ng","eng":"ng","er":"r"},
            "o" :{"1":"o","ou":"u"},

            "b" :{
                "1":"b",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "o":"o",
                "ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing",
                "u":"u","un":"un"
            },
            "p" :{
                "1":"p",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "o":"o","ou":"ou",
                "ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing",
                "u":"u"
            },
            "m" :{
                "1":"m",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "o":"o","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing","iu":"iu",
                "u":"u"
            },
            "f" :{
                "1":"f",
                "a":"a","an":"an","ag":"ang","ang":"ang",
                "o":"o","ou":"ou",
                "ei":"ei","en":"en","eg":"eng","eng":"eng",
                "iao":"iao",
                "u":"u"
            },

            "d" :{
                "1":"d",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","ei":"ei","eg":"eng","eng":"eng",
                "i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ig":"ing","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "t" :{
                "1":"t",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","eg":"eng","eng":"eng","ei":"ei",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","ig":"ing","ing":"ing",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "n" :{
                "1":"n",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iag":"iang","iang":"iang","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ue":"ue","uo":"uo","un":"un",
                "v":"v","ve":"ue"
            },
            "l" :{
                "1":"l",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","eg":"eng","eng":"eng",
                "i":"i","ia":"ia","ian":"ian","iag":"iang","iang":"iang","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un","uo":"uo",
                "v":"v","ve":"ue"
                },
            "g" :{
                "1":"g",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uag":"uang","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "k" :{
                "1":"k",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","eg":"eng","eng":"eng","ei":"ei",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uag":"uang","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "h" :{
                "1":"h",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uag":"uang","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },

            "j" :{
                "1":"j",
                "i":"i","ia":"ia","ian":"ian","iag":"iang","iang":"iang","iao":"iao",
                "ie":"ie",
                "in":"in","ig":"ing","ing":"ing",
                "iog":"iong","iong":"iong",
                "iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "q" :{
                "1":"q",
                "i":"i",
                "ia":"ia","ian":"ian","iag":"iang","iang":"iang","iao":"iao",
                "iog":"iong","iong":"iong",
                "ie":"ie",
                "in":"in","ig":"ing","ing":"ing",
                "iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "van":"uan","ve":"ue","vn":"un","v":"u"
            },
            "x" :{
                "1":"x",
                "i":"i",
                "ia":"ia","ian":"ian","iag":"iang","iang":"iang","iao":"iao",
                "iog":"iong","iong":"iong",
                "ie":"ie",
                "in":"in","ig":"ing","ing":"ing",
                "iu":"iu",
                "u":"u","uan":"uan","un":"un","ue":"ue",
                "van":"uan","ve":"ue","vn":"un","v":"u"
                },
            "zh":{
                "1":"zh",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uag":"uang","uang":"uang"
            },
            "ch":{
                "1":"ch",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uag":"uang","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "sh":{
                "1":"sh",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uag":"uang","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "r" :{
                "1":"r",
                "an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
                },
            "z" :{
                "1":"z",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "c" :{
                "1":"c",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "s" :{
                "1":"s",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","en":"en","eg":"eng","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "y" :{
                "1":"y",
                "a":"a","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "o":"o","og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e",
                "i":"i","in":"in","ig":"ing","ing":"ing",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "w" :{
                "1":"w",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang",
                "o":"o",
                "ei":"ei","en":"en","eg":"eng","eng":"eng",
                "u":"u"
            }
        }
    )

    ; yig -> yi ge?

    pinyin_table := JSON.Load(full_spelling_json)
    pinyin_table["l","ue"] := "ue"
    pinyin_table["n","ue"] := "ue"

    for key,value In zero_initials
    {
        zero_initials_table[value] := value
        if (StrLen(value)>1)
        {
            pinyin_table[t1:=SubStr(value, 1, 1)].Delete(value)
            pinyin_table[t1][t2:=SubStr(value, 2)]:=t2
        }
    }

    PinyinAssistantInitialize()
}
