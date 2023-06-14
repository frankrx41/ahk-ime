ImeTranslateFindResult(splitter_result_list, auto_complete, zero_weight:=true)
{
    if( ImeLanguageIsChinese() ){
        translate_result_list := PinyinTranslateFindResult(splitter_result_list, auto_complete)
    } else
    if( ImeLanguageIsJapanese() ) {
        translate_result_list := GojuonTranslateFindResult(splitter_result_list, auto_complete)
    }

    ImeProfilerBegin()
    debug_text := SplitterResultListGetDisplayTextGrace(splitter_result_list) "(" translate_result_list.Length() ")"
    if( !zero_weight ){
        TranslatorResultListFilterZeroWeight(translate_result_list)
        debug_text .= "->(" translate_result_list.Length() ")"
    }
    radical_list := []
    loop, % splitter_result_list.Length()
    {
        radical_list.Push(SplitterResultGetRadical(splitter_result_list[A_Index]))
    }
    if( radical_list.Length() > 0 ){
        TranslatorResultListFilterByRadical(translate_result_list, radical_list)
        debug_text .= "->(" translate_result_list.Length() ")"
    }
    if( true ){
        TranslatorResultListUniquify(translate_result_list)
        debug_text .= "->(" translate_result_list.Length() ")"
    }
    ImeProfilerEnd(debug_text)

    return translate_result_list
}
