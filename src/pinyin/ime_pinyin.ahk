;*******************************************************************************
;
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
    global auto_correct_table
    global bopomofo_table

    ; initials like z? c? s?
    if( SubStr(initials, 0, 1) == "?" )
    {
        initials_without_h := SubStr(initials, 1, 1)
        initials_with_h := initials_without_h . "h"
        return IsCompletePinyin(initials_with_h, vowels, tone) || IsCompletePinyin(initials_without_h, vowels, tone)
    }

    ; vowels content ?
    if( InStr(vowels, "?") )
    {
        ; Make sure same as `PinyinSqlFullKey`
        if( SubStr(vowels, -1, 2) == "n?" )
        {
            vowels_without_g := StrReplace(vowels, "?", "")
            vowels_with_g := StrReplace(vowels, "?", "g")
            return IsCompletePinyin(initials, vowels_without_g, tone) || IsCompletePinyin(initials, vowels_with_g, tone)
        }
        else if( SubStr(vowels, -2, 3) == "i?n" )
        {
            vowels_without_a := StrReplace(vowels, "?", "")
            vowels_with_a := StrReplace(vowels, "?", "a")
            return IsCompletePinyin(initials, vowels_without_a, tone) || IsCompletePinyin(initials, vowels_with_a, tone)
        }
        else
        {
            vowels := StrReplace(vowels, "?", ".")
            vowels := "^" vowels "$"
            for index, element in pinyin_table[initials]
            {
                if( RegExMatch(element, vowels) ){
                    return true
                }
            }
            return false
        }
    }
    else
    {
        is_complete := (IsZeroInitials(initials) && vowels == "") || (pinyin_table[initials, vowels]) || (auto_correct_table[initials, vowels]) || (bopomofo_table[initials, vowels])
        if( is_complete && tone )
        {
            is_complete := !IsBadTone(initials, vowels, tone)
        }
        return is_complete
    }
}

IsAutoCorrectPinyin(initials, vowels, tone:="'")
{
    global auto_correct_table
    return auto_correct_table[initials, vowels]
}

GetFullVowels(initials, vowels)
{
    global pinyin_table
    global auto_correct_table
    global bopomofo_table

    if( pinyin_table[initials][vowels] ) {
        return pinyin_table[initials][vowels]
    }
    else
    if( bopomofo_table[initials][vowels] ) {
        return bopomofo_table[initials][vowels]
    }
    else {
        return auto_correct_table[initials][vowels]
    }
}

GetFullInitials(initials)
{
    global pinyin_table
    return pinyin_table[initials][1]
}

IsInitials(initials)
{
    global pinyin_table
    if initials is not lower
    {
        return false
    }
    return pinyin_table.HasKey(initials)
}

IsZeroInitials(initials)
{
    global zero_initials_table
    return zero_initials_table.HasKey(initials)
}

IsInitialsAnyMark(char)
{
    return char == "+"
}

IsVowelsAnyMark(char)
{
    return char == "%"
}

;*******************************************************************************
;
IsTone(char)
{
    return char != "" && InStr("012345' ", char)
}

IsRadical(char)
{
    return char != "" && (InStr("AEOIUBPMFDTNLGKHJQXZCSRYWV", char, true) || InStr("!@#$^&", char, true))
}

GetRadical(input_string)
{
    RegExMatch(input_string, "^([A-Z!@#$^&]+)", radical)
    return radical
}

IsSymbol(char)
{
    global symbol_list_string
    return InStr(symbol_list_string, char)
}

;*******************************************************************************
; Initialize
PinyinInitialize()
{
    local
    global JSON
    global pinyin_table
    global auto_correct_table
    global bopomofo_table
    global smart_table
    global zero_initials_table := {}

    ; 零声母
    zero_initials := ["a","ai","an","ang","ao","e","ei","en","eng","er","o","ou","yu","%"]

    ; 全拼声母韵母表
    full_spelling_json =
    (LTrim
        {
            "a" :{"1":"a","ai":"i","an":"n","ang":"ng","ao":"o"},
            "e" :{"1":"e","ei":"i","en":"n","eng":"ng","er":"r"},
            "o" :{"1":"o","ou":"u"},

            "b" :{
                "1":"b",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "o":"o",
                "ei":"ei","en":"en","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing",
                "u":"u"
            },
            "p" :{
                "1":"p",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "o":"o","ou":"ou",
                "ei":"ei","en":"en","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing",
                "u":"u"
            },
            "m" :{
                "1":"m",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "o":"o","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu",
                "u":"u"
            },
            "f" :{
                "1":"f",
                "a":"a","an":"an","ang":"ang",
                "o":"o","ou":"ou",
                "ei":"ei","en":"en","eng":"eng",
                "iao":"iao",
                "u":"u"
            },

            "d" :{
                "1":"d",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","ei":"ei","eng":"eng",
                "i":"i","ia":"ia","ian":"ian","iao":"iao","ie":"ie","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "t" :{
                "1":"t",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","eng":"eng","ei":"ei",
                "i":"i","ian":"ian","iao":"iao","ie":"ie","ing":"ing",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "n" :{
                "1":"n",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ue":"ue","uo":"uo","un":"un",
                "v":"v","ve":"ue"
            },
            "l" :{
                "1":"l",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","ei":"ei","eng":"eng",
                "i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un","uo":"uo",
                "v":"v","ve":"ue"
            },
            "g" :{
                "1":"g",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "k" :{
                "1":"k",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","eng":"eng","ei":"ei",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "h" :{
                "1":"h",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "ong":"ong","ou":"ou",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },

            "j" :{
                "1":"j",
                "i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao",
                "ie":"ie",
                "in":"in","ing":"ing",
                "iong":"iong",
                "iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "q" :{
                "1":"q",
                "i":"i",
                "ia":"ia","ian":"ian","iang":"iang","iao":"iao",
                "iong":"iong",
                "ie":"ie",
                "in":"in","ing":"ing",
                "iu":"iu",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "x" :{
                "1":"x",
                "i":"i",
                "ia":"ia","ian":"ian","iang":"iang","iao":"iao",
                "iong":"iong",
                "ie":"ie",
                "in":"in","ing":"ing",
                "iu":"iu",
                "u":"u","uan":"uan","un":"un","ue":"ue",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "zh":{
                "1":"zh",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo","ua":"ua","uai":"uai","uang":"uang"
            },
            "ch":{
                "1":"ch",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","eng":"eng",
                "i":"i",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "sh":{
                "1":"sh",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo"
            },
            "r" :{
                "1":"r",
                "an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "z" :{
                "1":"z",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "c" :{
                "1":"c",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "s" :{
                "1":"s",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "ong":"ong","ou":"ou",
                "e":"e","en":"en","eng":"eng",
                "i":"i",
                "u":"u","uan":"uan","ui":"ui","un":"un","uo":"uo"
            },
            "y" :{
                "1":"y",
                "a":"a","an":"an","ang":"ang","ao":"ao",
                "o":"o","ong":"ong","ou":"ou",
                "e":"e",
                "i":"i","in":"in","ing":"ing",
                "u":"u","uan":"uan","ue":"ue","un":"un",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            },
            "w" :{
                "1":"w",
                "a":"a","ai":"ai","an":"an","ang":"ang",
                "o":"o",
                "ei":"ei","en":"en","eng":"eng",
                "u":"u"
            },
            "yu" :{
                "1":"yu",
                "e":"e","an":"an","n":"n"
            },

            "`%" :{
                "1":"`%",
                "a":"a","ai":"ai","an":"an","ang":"ang","ao":"ao",
                "o":"o","ong":"ong","ou":"ou",
                "e":"e","ei":"ei","en":"en","eng":"eng",
                "i":"i","ia":"ia","ian":"ian","iang":"iang","iao":"iao","ie":"ie","in":"in","ing":"ing","iu":"iu",
                "u":"u","ua":"ua","uai":"uai","uan":"uan","uang":"uang","ui":"ui","un":"un","uo":"uo","ue":"ue",
                "v":"u","van":"uan","ve":"ue","vn":"un"
            }
        }
    )

    pinyin_table := JSON.Load(full_spelling_json)
    for key,value In zero_initials
    {
        zero_initials_table[value] := value
        if (StrLen(value)>1)
        {
            pinyin_table[t1:=SubStr(value, 1, 1)].Delete(value)
            pinyin_table[t1][t2:=SubStr(value, 2)]:=t2
        }
    }

    auto_correct_json =
    (LTrim
        {
            "b" :{
                "ain":"ian","oa":"ao",
                "eg":"eng","ag":"ang","ig":"ing"
            },
            "p" :{
                "aio":"iao","ain":"ian","oa":"ao",
                "eg":"eng","ag":"ang","ig":"ing"
            },
            "m" :{
                "aio":"iao","ain":"ian","oa":"ao",
                "eg":"eng","ag":"ang","ig":"ing"
            },
            "f" :{
                "ie":"ei",
                "eg":"eng","ag":"ang"
            },
            "d" :{
                "aio":"iao","ain":"ian","aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","ig":"ing"
            },
            "t" :{
                "aio":"iao","ain":"ian","aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","ig":"ing"
            },
            "n" :{
                "aio":"iao","ain":"ian","aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","iag":"iang","ig":"ing"
            },
            "l" :{
                "aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","iag":"iang","ig":"ing"
            },
            "g" :{
                "aui":"uai","aun":"uan","ie":"ei","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","uag":"uang"
            },
            "k" :{
                "aui":"uai","aun":"uan","ie":"ei","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","uag":"uang"
            },
            "h" :{
                "aui":"uai","aun":"uan","ie":"ei","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","uag":"uang"
            },
            "j" :{
                "aio":"iao","ain":"ian","aun":"uan",
                "iag":"iang","ig":"ing","iog":"iong"
            },
            "q" :{
                "aio":"iao","ain":"ian","aun":"uan",
                "iag":"iang","iog":"iong","ig":"ing"
            },
            "x" :{
                "aio":"iao","ain":"ian","aun":"uan",
                "iag":"iang","iog":"iong","ig":"ing"
            },
            "zh":{
                "aui":"uai","aun":"uan","ie":"ei","oa":"ao",
                "ag":"ang","o":"ong","og":"ong","on":"ong","uag":"uang"
            },
            "ch":{
                "aui":"uai","aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong","uag":"uang"
            },
            "sh":{
                "aui":"uai","aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","uag":"uang"
            },
            "r" :{
                "aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong"
            },
            "z" :{
                "aun":"uan","ie":"ei","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong"
            },
            "c" :{
                "aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong"
            },
            "s" :{
                "aun":"uan","oa":"ao",
                "eg":"eng","ag":"ang","o":"ong","og":"ong","on":"ong"
            },
            "y" :{
                "aun":"uan","oa":"ao",
                "ag":"ang","og":"ong","on":"ong"
            },
            "w" :{
                "ie":"ei",
                "eg":"eng","ag":"ang"
            }
        }
    )
    auto_correct_table := JSON.Load(auto_correct_json)

    bopomofo_spelling_json =
    (LTrim
        {
            "b" :{
                "ien":"in","ieng":"ing"
            },
            "p" :{
                "ien":"in","ieng":"ing"
            },
            "m" :{
                "ien":"in","ieng":"ing"
            },
            "f" :{

            },
            "d" :{
                "ieng":"ing","ven":"un","uen":"un","ueng":"ong"
            },
            "t" :{
                "ieng":"ing","ven":"un","uen":"un","ueng":"ong"
            },
            "n" :{
                "ien":"in","ieng":"ing","ueng":"ong"
            },
            "l" :{
                "ien":"in","ieng":"ing","ven":"un","uen":"un","ueng":"ong"
            },
            "g" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "k" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "h" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "j" :{
                "ien":"in","ieng":"ing","veng":"iong"
            },
            "q" :{
                "ien":"in","ieng":"ing","veng":"iong"
            },
            "x" :{
                "ien":"in","ieng":"ing","veng":"iong"
            },
            "zh" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "ch" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "sh" :{
                "ven":"un","uen":"un"
            },
            "r" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "z" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "c" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "s" :{
                "ven":"un","uen":"un","ueng":"ong"
            },
            "y" :{
                "ien":"in","ieng":"ing","ven":"un","uen":"un","ueng":"ong","veng":"ong","eng":"ong"
            },
            "w" :{

            },
            "yu" :{
                "e":"e","an":"an","un":"un"
            }
        }
    )
    bopomofo_table := JSON.Load(bopomofo_spelling_json)

    smart_spelling_json =
    (LTrim
        {
            "b" :{
                "a":"a","o":"o","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao",
                "an":"an","en":"en","ang":"ang","eng":"eng",
                "iao":"iao","ie":"ie","ian":"ian","in":"in","ing":"ing"
            },
            "p" :{
                "a":"a","o":"o","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng",
                "iao":"iao","ie":"ie","ian":"ian","in":"in","ing":"ing"
            },
            "m" :{
                "a":"a","o":"o","e":"e","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng",
                "iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","ing":"ing"
            },
            "f" :{
                "a":"a","o":"o","u":"u",
                "ei":"ei","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng"
            },

            "d" :{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "iao":"iao","ie":"ie","iu":"iu","ian":"ian","ing":"ing",
                "uo":"uo","ui":"ui","uan":"uan","un":"un"
            },
            "t" :{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ao":"ao","ou":"ou",
                "an":"an","ang":"ang","eng":"eng","ong":"ong",
                "iao":"iao","ie":"ie","ian":"ian","ing":"ing",
                "uo":"uo","ui":"ui","uan":"uan","un":"un"
            },
            "n" :{
                "a":"a","e":"e","i":"i","u":"u","v":"v",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","iang":"iang","ing":"ing",
                "uo":"uo","uan":"uan",
                "ve":"ue","ue":"ue"
            },
            "l" :{
                "a":"a","e":"e","i":"i","u":"u","v":"v",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","ang":"ang","eng":"eng","ong":"ong",
                "iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","iang":"iang","ing":"ing",
                "uo":"uo","uan":"uan","un":"un",
                "ve":"ue","ue":"ue"
            },
            "g" :{
                "a":"a","e":"e","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },
            "k" :{
                "a":"a","e":"e","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },
            "h" :{
                "a":"a","e":"e","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },

            "j" :{
                "i":"i","v":"u","u":"u",
                "ia":"ia","iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","iang":"iang","ing":"ing","iong":"iong",
                "ve":"ue","ue":"ue","van":"uan","uan":"uan","vn":"un","un":"un"
            },
            "q" :{
                "i":"i","v":"u","u":"u",
                "ia":"ia","iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","iang":"iang","ing":"ing","iong":"iong",
                "ve":"ue","ue":"ue","van":"uan","uan":"uan","vn":"un","un":"un"
            },
            "x" :{
                "i":"i","v":"u","u":"u",
                "ia":"ia","iao":"iao","ie":"ie","iu":"iu","ian":"ian","in":"in","iang":"iang","ing":"ing","iong":"iong",
                "ve":"ue","ue":"ue","van":"uan","uan":"uan","vn":"un","un":"un"
            },

            "zh":{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },
            "ch":{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },
            "sh":{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng",
                "ua":"ua","uo":"uo","uai":"uai","ui":"ui","uan":"uan","un":"un","uang":"uang"
            },
            "r" :{
                "e":"e","i":"i","u":"u",
                "ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "ua":"ua","uo":"uo","ui":"ui","uan":"uan","un":"un"
            },

            "z" :{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ei":"ei","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "uo":"uo","ui":"ui","uan":"uan","un":"un"
            },
            "c" :{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "uo":"uo","ui":"ui","uan":"uan","un":"un"
            },
            "s" :{
                "a":"a","e":"e","i":"i","u":"u",
                "ai":"ai","ao":"ao","ou":"ou",
                "an":"an","en":"en","ang":"ang","eng":"eng","ong":"ong",
                "uo":"uo","ui":"ui","uan":"uan","un":"un"
            },
            "y" :{
                "a":"a","o":"o","e":"e","i":"i","v":"u","u":"u",
                "ao":"ao","ou":"ou",
                "an":"an","ang":"ang","ong":"ong",
                "in":"in","ing":"ing",
                "ve":"ue","ue":"ue","van":"uan","uan":"uan","vn":"un","un":"un"
            },
            "w" :{
                "a":"a","o":"o","u":"u",
                "ai":"ai","ei":"ei",
                "an":"an","en":"en","ang":"ang","eng":"eng"
            },
            "yu" :{
                "e":"e","an":"an","n":"n"
            }
        }
    )
    smart_table := JSON.Load(smart_spelling_json)
}
