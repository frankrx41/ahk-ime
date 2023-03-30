IsBadTone(initials, vowels, tone)
{
    static pinyin_bad_tones
    pinyin_bad_tones := { "a3": 1
        ,"a4": 1
        ,"ca2": 1
        ,"ce1": 1
        ,"ce2": 1
        ,"ce3": 1
        ,"de3": 1
        ,"de4": 1
        ,"er1": 1
        ,"fo1": 1
        ,"fo3": 1
        ,"fo4": 1
        ,"ɡa1": 1
        ,"ɡa2": 1
        ,"ɡa3": 1
        ,"ɡa4": 1
        ,"ɡe1": 1
        ,"ɡe2": 1
        ,"ɡe3": 1
        ,"ɡe4": 1
        ,"ɡu1": 1
        ,"ɡu2": 1
        ,"ɡu3": 1
        ,"ɡu4": 1
        ,"he3": 1
        ,"ka2": 1
        ,"ka4": 1
        ,"ku2": 1
        ,"le2": 1
        ,"le3": 1
        ,"lo1": 1
        ,"lo2": 1
        ,"lo3": 1
        ,"lo4": 1
        ,"lv1": 1
        ,"me3": 1
        ,"me4": 1
        ,"mu1": 1
        ,"ne1": 1
        ,"ne3": 1
        ,"nu1": 1
        ,"nv1": 1
        ,"nv2": 1
        ,"ou2": 1
        ,"pa3": 1
        ,"re1": 1
        ,"ri1": 1
        ,"ri2": 1
        ,"ri3": 1
        ,"ru1": 1
        ,"sa2": 1
        ,"se2": 1
        ,"se3": 1
        ,"si2": 1
        ,"su3": 1
        ,"te1": 1
        ,"te2": 1
        ,"te3": 1
        ,"wo2": 1
        ,"yo2": 1
        ,"yo3": 1
        ,"yo4": 1
        ,"ze1": 1
        ,"ze3": 1 }
    return pinyin_bad_tones.HasKey(initials . vowels . tone)
}

IsCompletePinyin(initials, vowels, tone:="'")
{
    global pinyin_table
    ; Not suport check like j-an%
    if( InStr(vowels, "%") ){
        return true
    }

    ; initials like z% c% s%
    initials_has_miss_char := SubStr(initials, 0, 1 ) == "%"
    if( initials_has_miss_char )
    {
        initials_without_h := SubStr(initials, 1, 1)
        initials_with_h := initials_without_h . "h"
        return IsCompletePinyin(initials_with_h, vowels, tone) || IsCompletePinyin(initials_without_h, vowels, tone)
    }

    is_complete := is_complete := (IsZeroInitials(initials) && vowels == "") || (pinyin_table[initials, vowels])
    if( is_complete && tone )
    {
        is_complete := !IsBadTone(initials, vowels, tone)
    }
    return is_complete
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

IsZeroInitials(initials)
{
    global zero_initials_table
    return zero_initials_table.HasKey(initials)
}

PinyinInitialize()
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
                "u":"u",
                "aio": "iao"

            },
            "m" :{
                "1":"m",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "o":"o","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing","iu":"iu",
                "u":"u",
                "aio": "iao"
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
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo",
                "aio": "iao"
            },
            "t" :{
                "1":"t",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","eg":"eng","eng":"eng","ei":"ei",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","ig":"ing","ing":"ing",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo",
                "aio": "iao"
            },
            "n" :{
                "1":"n",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eg":"eng","eng":"eng",
                "i":"i","ian":"ian","iag":"iang","iang":"iang","iao":"iao","ie":"ie","in":"in","ig":"ing","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ue":"ue","uo":"uo","un":"un",
                "v":"v","ve":"ue",
                "aio": "iao"
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
                "v":"u","van":"uan","ve":"ue","vn":"un",
                "aio": "iao"
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
                "van":"uan","ve":"ue","vn":"un","v":"u",
                "aio": "iao"
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
                "van":"uan","ve":"ue","vn":"un","v":"u",
                "aio": "iao"
            },
            "zh":{
                "1":"zh",
                "a":"a","ai":"ai","an":"an","ag":"ang","ang":"ang","ao":"ao",
                "og":"ong","on":"ong","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
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
                "i":"i","in":"in","ing":"ing",
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

    PinyinHistoryClear()
    PinyinRadicalInitialize()
    PinyinSplitTableInitialize()
    PinyinTraditionalInitialize()
}
