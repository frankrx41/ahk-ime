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
        if (Byacc)
        {
            if( !init && !(init:=DllCall("GetModuleHandle", "Str", "oleacc", "Ptr")) )
            {
                init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
                VarSetCapacity(IID,16)
                idObject := OBJID_CARET := 0xFFFFFFF8
                pacc:=0
                NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
                NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
            }
            Hwnd := WinExist("A")
            if( DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd, "UInt",idObject, "Ptr",&IID, "Ptr*",pacc) == 0 )
            {
                Acc := ComObject(9,pacc,1)
                ObjAddRef(pacc)
                try{
                    Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
                    CaretX := NumGet(x,0,"int")
                    CaretY := NumGet(y,0,"int")
                    CaretH := NumGet(h,0,"int")
                }
            }
        }
        if( Caretx=0&&Carety=0 ){
            MouseGetPos, x, y, Hwnd
            return {x:x,y:y,h:30,t:"Mouse",Hwnd:Hwnd}
        } else {
            return {x:Caretx,y:Carety,h:Max(Careth,30),t:"Acc",Hwnd:Hwnd}
        }
    } else {
        return {x:A_CaretX,y:A_CaretY,h:30,t:"Caret",Hwnd:Hwnd}
    }
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

TooltipInfoBlock(info, delay:=500)
{
    ToolTip, %info%
    Sleep, %delay%
    ToolTip,
}

ScriptRestart()
{
    TooltipInfoBlock("Reload " A_ScriptName)
    Reload
}

PutStringTimer:
    Critical
    SendInput, % "{Text}" global_input_string
return

PutString(input_string, use_clipboard:=false){
    local
    global global_input_string
    Critical
    if( !use_clipboard ){
        global_input_string := input_string
        SetTimer, PutStringTimer, -1
    }
    else {
        saveboard := clipboard
        clipboard := input_string
        Send, {RCtrl Down}v{RCtrl Up}
        clipboard := saveboard
    }
}

; https://www.autohotkey.com/boards/viewtopic.php?t=49297
/* ObjectSort() by bichlepa
* 
* Description:
*    Reads content of an object and returns a sorted array
* 
* Parameters:
*    obj:              Object which will be sorted
*    keyName:          [optional] 
*                      Omit it if you want to sort a array of strings, numbers etc.
*                      If you have an array of objects, specify here the key by which contents the object will be sorted.
*    callBackFunction: [optional] Use it if you want to have custom sort rules.
*                      The function will be called once for each value. It must return a number or string.
*    reverse:          [optional] Pass true if the result array should be reversed
*/
ObjectSort(obj, keyName="", callbackFunc="", reverse=false)
{
    temp := Object()
    sorted := Object() ;Return value
    
    for oneKey, oneValue in obj
    {
        ;Get the value by which it will be sorted
        if keyname
            value := oneValue[keyName]
        else
            value := oneValue
        
        ;If there is a callback function, call it. The value is the key of the temporary list.
        if (callbackFunc)
            tempKey := %callbackFunc%(value)
        else
            tempKey := value
        
        ;Insert the value in the temporary object.
        ;It may happen that some values are equal therefore we put the values in an array.
        if not isObject(temp[tempKey])
            temp[tempKey] := []
        temp[tempKey].push(oneValue)
    }
    
    ;Now loop throuth the temporary list. AutoHotkey sorts them for us.
    for oneTempKey, oneValueList in temp
    {
        for oneValueIndex, oneValue in oneValueList
        {
            ;And add the values to the result list
            if (reverse)
                sorted.insertAt(1,oneValue)
            else
                sorted.push(oneValue)
        }
    }
    
    return sorted
}

;*******************************************************************************
; https://www.autohotkey.com/boards/viewtopic.php?t=6413
LoadLibrary(filename)
{
    static ref := {}
    if (!(ptr := p := DllCall("LoadLibrary", "str", filename, "ptr")))
        return 0
    ref[ptr,"count"] := (ref[ptr]) ? ref[ptr,"count"]+1 : 1
    p += NumGet(p+0, 0x3c, "int")+24
    o := {_ptr:ptr, __delete:func("FreeLibrary"), _ref:ref[ptr]}
    if (NumGet(p+0, (A_PtrSize=4) ? 92 : 108, "uint")<1 || (ts := NumGet(p+0, (A_PtrSize=4) ? 96 : 112, "uint")+ptr)=ptr || (te := NumGet(p+0, (A_PtrSize=4) ? 100 : 116, "uint")+ts)=ts)
        return o
    n := ptr+NumGet(ts+0, 32, "uint")
    loop % NumGet(ts+0, 24, "uint")
    {
        if (p := NumGet(n+0, (A_Index-1)*4, "uint"))
        {
            o[f := StrGet(ptr+p, "cp0")] := DllCall("GetProcAddress", "ptr", ptr, "astr", f, "ptr")
            if (Substr(f, 0)==((A_IsUnicode) ? "W" : "A"))
                o[Substr(f, 1, -1)] := o[f]
        }
    }
    return o
}

FreeLibrary(lib)
{
    if (lib._ref.count>=1)
        lib._ref.count -= 1
    if (lib._ref.count<1)
        DllCall("FreeLibrary", "ptr", lib._ptr)
}
