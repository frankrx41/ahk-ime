; 字符上屏
PutCharacter(str, mode:=""){
    Critical
    SendInput, % "{Text}" str
}

; https://www.autohotkey.com/boards/viewtopic.php?t=86355
CmdRet(sCmd, callBackFuncObj := "", encoding := "CP0")
{
    ; MsgBox, %sCmd%
    static HANDLE_FLAG_INHERIT := 0x00000001, flags := HANDLE_FLAG_INHERIT
        , STARTF_USESTDHANDLES := 0x100, CREATE_NO_WINDOW := 0x08000000
    hPipeRead:=""
    hPipeWrite:=""
    sOutput:=""
    DllCall("CreatePipe", "PtrP", hPipeRead, "PtrP", hPipeWrite, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hPipeWrite, "UInt", flags, "UInt", HANDLE_FLAG_INHERIT)

    VarSetCapacity(STARTUPINFO , siSize := A_PtrSize*4 + 4*8 + A_PtrSize*5, 0)
    NumPut(siSize , STARTUPINFO)
    NumPut(STARTF_USESTDHANDLES, STARTUPINFO, A_PtrSize*4 + 4*7)
    NumPut(hPipeWrite , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*3)
    NumPut(hPipeWrite , STARTUPINFO, A_PtrSize*4 + 4*8 + A_PtrSize*4)

    VarSetCapacity(PROCESS_INFORMATION, A_PtrSize*2 + 4*2, 0)
    if !DllCall("CreateProcess", "Ptr", 0, "Str", sCmd, "Ptr", 0, "Ptr", 0, "UInt", true, "UInt", CREATE_NO_WINDOW
        , "Ptr", 0, "Ptr", 0, "Ptr", &STARTUPINFO, "Ptr", &PROCESS_INFORMATION)
    {
        DllCall("CloseHandle", "Ptr", hPipeRead)
        DllCall("CloseHandle", "Ptr", hPipeWrite)
        throw Exception("CreateProcess is failed")
    }
    DllCall("CloseHandle", "Ptr", hPipeWrite)
    VarSetCapacity(sTemp, 4096), nSize := 0
    while DllCall("ReadFile", "Ptr", hPipeRead, "Ptr", &sTemp, "UInt", 4096, "UIntP", nSize, "UInt", 0) {
        sOutput .= stdOut := StrGet(&sTemp, nSize, encoding)
        ;sOutput .= stdOut := StrGet(&sTemp, nSize)
        ;sOutput .= stdOut := StrGet(&sTemp, nSize, CPX)
        ( callBackFuncObj && callBackFuncObj.Call(stdOut) )
    }
    DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION))
    DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize))
    DllCall("CloseHandle", "Ptr", hPipeRead)
    Return sOutput
}

; 获取光标坐标
GetCaretPos(Byacc:=1){
    Static init:=0
    local Hwnd:=0
    if (A_CaretX=""){
        Caretx:=Carety:=CaretH:=CaretW:=0
        if (Byacc){
            if (!init && !(init:=DllCall("GetModuleHandle", "Str", "oleacc", "Ptr")))
                init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
            VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8, pacc:=0
            , NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
            , NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
            if (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd:=WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
                Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
                Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
                , CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
            }
        }
        if (Caretx=0&&Carety=0){
            MouseGetPos, x, y, Hwnd
            return {x:x,y:y,h:30,t:"Mouse",Hwnd:Hwnd}
        } else
            return {x:Caretx,y:Carety,h:Max(Careth,30),t:"Acc",Hwnd:Hwnd}
    } else
        return {x:A_CaretX,y:A_CaretY,h:30,t:"Caret",Hwnd:Hwnd}
}

; 复制对象
CopyObj(obj){
    if !IsObject(obj){
        retObj:=obj
    } else {
        retObj := {}
        For k, v In obj
            retObj[k] := CopyObj(v)
    }
    return retObj
}

OutputDebug(info,type){
    static buffer:=""
    switch type
    {
        case 1:
            FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
            FileAppend, % Now "`n" info "`n", debug.log, UTF-8
        case 2:
            OutputDebug % info
        case 3:
            MsgBox, 16, 错误, % StrReplace(info, "|", "`n")
        case 4:
            buffer .= info "    "
            SetTimer, writeintolog, -1000
        Default:
            return
    }
    return
    writeintolog:
        FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
        FileAppend, % Now "`n" buffer "`n", debug.log, UTF-8
        ; OutputDebug % buffer
        buffer:=""
    return
}

GetSelectText(timeout := 0.5)
{
    IfWinActive, ahk_class ConsoleWindowClass
    {
        return ""
    } else {
        ; OnClipboardChange("ClipChanged",0)
        saveboard := clipboard
        clipboard :=
        SendInput, {RCtrl Down}c{RCtrl Up}
        ClipWait, %timeout%
        copyboard := clipboard
        clipboard := saveboard
        ;OnClipboardChange("ClipChanged",1)
        return copyboard
    }
}
