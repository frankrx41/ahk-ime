ImeSelectorSingleModeInitialize()
{
    global ime_selector_single_mode
}

ImeSelectorSingleModeClear()
{
    global ime_selector_single_mode
    ime_selector_single_mode := 0
}

;*******************************************************************************
;
ImeSelectorToggleSingleMode()
{
    global ime_selector_single_mode
    ime_selector_single_mode := !ime_selector_single_mode
    ImeCandidateSetSingleMode(ime_selector_single_mode)
    ImeSelectorFixupSelectIndex(ImeCandidateGet())
}
