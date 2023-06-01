; Lib
#Include, src\utils\ime_func.ahk
#Include, src\utils\ime_assert.ahk
#Include, src\utils\ime_profiler.ahk
#Include, src\utils\ime_debug.ahk

; Version
#Include, src\ime_version.ahk

; Hotkey
#Include, src\hotkey\ime_hotkey.ahk
#Include, src\hotkey\ime_hotkey_event.ahk
#Include, src\hotkey\ime_hotkey_register.ahk

; Inputer
#Include, src\components\inputter\ime_inputter.ahk

; Spliter
#Include, src\components\splitter\lib_splitter_result.ahk

; Candidate
#Include, src\components\candidate\ime_candidate.ahk
#Include, src\components\candidate\lib_candidate_result.ahk

; Translator
#Include, src\components\translator\ime_translator.ahk
#Include, src\components\translator\lib_translator_result.ahk

; Filter
#Include, src\components\filter\lib_translator_list_filter.ahk
#Include, src\components\filter\lib_translator_list_radical.ahk
#Include, src\components\filter\lib_translator_list_uniquify.ahk

; pinyin
#Include, src\pinyin\ime_pinyin.ahk
#Include, src\pinyin\ime_pinyin_sql.ahk
#Include, src\pinyin\ime_pinyin_splitter.ahk
#Include, src\pinyin\ime_pinyin_translator.ahk
#Include, src\pinyin\ime_pinyin_translator_auto_complete.ahk
#Include, src\pinyin\ime_pinyin_translator_combine_word.ahk
#Include, src\pinyin\ime_pinyin_translator_traditional.ahk

; gojuon
#Include, src\gojuon\ime_gojuon_splitter.ahk
#Include, src\gojuon\ime_gojuon_translator.ahk

; Selector
#Include, src\components\selector\ime_selector.ahk
#Include, src\components\selector\lib_selector_result.ahk
#Include, src\components\selector\lib_selector_fixup.ahk

; Outputter
#Include, src\components\outputter\ime_outputter.ahk

; UI
#Include, src\ui\ime_state.ahk
#Include, src\ui\ime_select_menu.ahk
#Include, src\ui\ime_tooltip.ahk
#Include, src\ui\ime_word_creator.ahk

; DB
#Include, src\utils\ime_db.ahk

; Third part lib
#Include, lib\ToolTip.ahk
#Include, lib\SQLiteDB.ahk
#Include, lib\JSON.ahk
