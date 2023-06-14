ImeTranslateFindResult(splitter_result_list, auto_complete, keep_zero_weight:=true)
{
    if( ImeLanguageIsChinese() ){
        translate_result_list := PinyinTranslateFindResult(splitter_result_list, auto_complete)
    } else
    if( ImeLanguageIsJapanese() ) {
        translate_result_list := GojuonTranslateFindResult(splitter_result_list, auto_complete)
    }

    ImeTranslateFilterResult(translate_result_list, splitter_result_list, keep_zero_weight)
    return translate_result_list
}

ImeTranslateFilterResult(ByRef translate_result_list, splitter_result_list, keep_zero_weight)
{
    ImeProfilerBegin()
    debug_text := SplitterResultListGetDisplayTextGrace(splitter_result_list) "(" translate_result_list.Length() ")"
    if( !keep_zero_weight ){
        TranslatorResultListFilterZeroWeight(translate_result_list)
        debug_text .= "-w->(" translate_result_list.Length() ")"
    }
    radical_list := []
    need_check_radical := false
    loop, % splitter_result_list.Length()
    {
        radical_text := SplitterResultGetRadical(splitter_result_list[A_Index])
        radical_list.Push(radical_text)
        if( radical_text ){
            need_check_radical := true
        }
    }
    if( need_check_radical ){
        TranslatorResultListFilterByRadical(translate_result_list, radical_list)
        debug_text .= "-r->(" translate_result_list.Length() ")"
    }
    if( true ){
        TranslatorResultListUniquify(translate_result_list)
        debug_text .= "-u->(" translate_result_list.Length() ")"
    }
    ImeProfilerEnd(debug_text)
}
