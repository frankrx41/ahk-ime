;*******************************************************************************
; Verion info
;
; 
IsDebugVersion()
{
    return false
}

GetVersion()
{
    return "0.4.4"
}

GetGitHash()
{
    static git_hash := ""
    static has_get_git_hash := false
    if( !has_get_git_hash ){
        git_hash := RTrim(CmdRet("git rev-parse --short HEAD"), "`n")
    }
    return git_hash
}

GetVersionText()
{
    static version_text := ""
    if( !version_text )
    {
        version_text := ""
        version_text .= "v"
        version_text .= GetVersion()
        if( IsDebugVersion() ) {
            version_text .= " (dev)"
            version_text .= " " GetGitHash()
        }
    }
    ; MsgBox, % version_text
    return version_text
}
