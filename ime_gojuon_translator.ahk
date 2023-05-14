GojuonTranslateInitialize()
{
    gojuon_list_json =
    (LTrim
        {
            "a": ["あ", "ア"], "i": ["い", "イ"], "u": ["う", "ウ"], "e": ["え", "エ"], "o": ["お", "オ"],
            "ka": ["か", "カ"], "ki": ["き", "キ"], "ku": ["く", "ク"], "ke": ["け", "ケ"], "ko": ["こ", "コ"],
            "sa": ["さ", "サ"], "si": ["し", "シ"], "su": ["す", "ス"], "se": ["せ", "セ"], "so": ["そ", "ソ"],
            "ta": ["た", "タ"], "ti": ["ち", "チ"], "tu": ["つ", "ツ"], "te": ["て", "テ"], "to": ["と", "ト"],
            "na": ["な", "ナ"], "ni": ["に", "ニ"], "nu": ["ぬ", "ヌ"], "ne": ["ね", "ネ"], "no": ["の", "ノ"],
            "ha": ["は", "ハ"], "hi": ["ひ", "ヒ"], "hu": ["ふ", "フ"], "he": ["へ", "ヘ"], "ho": ["ほ", "ホ"],
            "ma": ["ま", "マ"], "mi": ["み", "ミ"], "mu": ["む", "ム"], "me": ["め", "メ"], "mo": ["も", "モ"],
            "ya": ["や", "ヤ"], "yi": ["茶", "茶"], "yu": ["ゆ", "ユ"], "ye": ["𛀁", "茶"], "yo": ["よ", "ヨ"],
            "ra": ["ら", "ラ"], "ri": ["り", "リ"], "ru": ["る", "ル"], "re": ["れ", "レ"], "ro": ["ろ", "ロ"],
            "wa": ["わ", "ワ"], "wi": ["ゐ", "ヰ"], "wu": ["茶", "茶"], "we": ["ゑ", "ヱ"], "wo": ["を", "ヲ"],
            "n": ["ん", "ン"],
            "nn": ["ん", "ン"],
            "shi": ["し", "シ"],
            "tsu": ["つ", "ツ"],
            "chi": ["ち", "チ"],
            "fu": ["ふ", "フ"],
            "ga": ["が", "ガ"], "za": ["ざ", "ザ"], "da": ["だ", "ダ"], "ba": ["ば", "バ"],
            "gi": ["ぎ", "ギ"], "ji": ["じ", "ジ"], "di": ["ぢ", "ヂ"], "bi": ["び", "ビ"],
            "gu": ["ぐ", "グ"], "zu": ["ず", "ズ"], "du": ["づ", "ヅ"], "bu": ["ぶ", "ブ"],
            "ge": ["げ", "ゲ"], "ze": ["ぜ", "ゼ"], "de": ["で", "デ"], "be": ["べ", "ベ"],
            "go": ["ご", "ゴ"], "zo": ["ぞ", "ゾ"], "do": ["ど", "ド"], "bo": ["ぼ", "ボ"],
            "zi": ["ぢ", "ヂ"],
            "pa": ["ぱ", "パ"],
            "pi": ["ぴ", "ピ"],
            "pu": ["ぷ", "プ"],
            "pe": ["ぺ", "ペ"],
            "po": ["ぽ", "ポ"],
            "t": ["っ", "ッ"],
            
            "kya": ["きゃ", "キャ"], "kyu": ["きゅ", "キュ"], "kyo": ["きょ", "キョ"],
            "sha": ["しゃ", "シャ"], "shu": ["しゅ", "シュ"], "sho": ["しょ", "ショ"],
            "cha": ["ちゃ", "チャ"], "chu": ["ちゅ", "チュ"], "cho": ["ちょ", "チョ"],
            "nya": ["にゃ", "ニャ"], "nyu": ["にゅ", "ニュ"], "nyo": ["にょ", "ニョ"],
            "hya": ["ひゃ", "ヒャ"], "hyu": ["ひゅ", "ヒュ"], "hyo": ["ひょ", "ヒョ"],
            "mya": ["みゃ", "ミャ"], "myu": ["みゅ", "ミュ"], "myo": ["みょ", "ミョ"],
            "rya": ["りゃ", "リャ"], "ryu": ["りゅ", "リュ"], "ryo": ["りょ", "リョ"],
            "gya": ["ぎゃ", "ギャ"], "gyu": ["ぎゅ", "ギュ"], "gyo": ["ぎょ", "ギョ"],
            "zya": ["じゃ", "ジャ"], "zyu": ["じゅ", "ジュ"], "zyo": ["じょ", "ジョ"],
            "dya": ["ぢゃ", "ヂャ"], "dyu": ["ぢゅ", "ヂュ"], "dyo": ["ぢょ", "ヂョ"],
            "bya": ["びゃ", "ビャ"], "byu": ["びゅ", "ビュ"], "byo": ["びょ", "ビョ"],
            "pya": ["ぴゃ", "ピャ"], "pyu": ["ぴゅ", "ピュ"], "pyo": ["ぴょ", "ピョ"],
            "ja": ["じゃ", "ジャ"], "ju": ["じゅ", "ジュ"], "jo": ["じょ", "ジョ"],
            "jya": ["じゃ", "ジャ"], "jyu": ["じゅ", "ジュ"], "jyo": ["じょ", "ジョ"],

            "-": ["ー", "ー"]
        }
    )
    global ime_gojuon_list := JSON.Load(gojuon_list_json)
}

GojuonTranslateFindResult(splitter_result, auto_complete)
{
    global ime_gojuon_list

    splitted_string := SplitterResultGetPinyin(splitter_result[1])
    if( ime_gojuon_list.HasKey(splitted_string) )
    {
        gojuon := ime_gojuon_list[splitted_string]
        translate_result_list := [TranslatorResultMake(splitted_string, gojuon[1], 0, "", 1, splitted_string) 
            ,TranslatorResultMake(splitted_string, gojuon[2], 1, "", 1, splitted_string)]
    }
    else
    {
        translate_result_list := [TranslatorResultMake(splitted_string, splitted_string, 1, "", 1, splitted_string)]
    }

    return translate_result_list
}

; PinyinTranslateFindResult(splitter_result, auto_complete)
