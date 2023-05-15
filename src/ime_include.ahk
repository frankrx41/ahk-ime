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
#Include, src\components\ime_inputter.ahk

; Spliter
#Include, src\components\ime_splitter_result.ahk

; Candidate
#Include, src\components\ime_candidate.ahk
#Include, src\components\ime_candidate_result.ahk

; Translator
#Include, src\components\ime_translator_history.ahk
#Include, src\components\ime_translator_result.ahk

; Filter
#Include, src\components\ime_translator_list_filter.ahk
#Include, src\components\ime_translator_list_radical.ahk
#Include, src\components\ime_translator_list_uniquify.ahk

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
#Include, src\components\ime_selector.ahk
#Include, src\components\ime_selector_result.ahk
#Include, src\components\ime_selector_fixup.ahk

; Outputter
#Include, src\components\ime_outputter.ahk

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
