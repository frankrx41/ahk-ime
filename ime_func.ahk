; 字符上屏
PutCharacter(str, mode:=""){
	Critical
	SendInput, % "{Text}" str
}

; 获取光标坐标
GetCaretPos(Byacc:=1){
	Static init:=0
	Hwnd:=0
	If (A_CaretX=""){
		Caretx:=Carety:=CaretH:=CaretW:=0
		If (Byacc){
			If (!init && !(init:=DllCall("GetModuleHandle", "Str", "oleacc", "Ptr")))
				init:=DllCall("LoadLibrary","Str","oleacc","Ptr")
			VarSetCapacity(IID,16), idObject:=OBJID_CARET:=0xFFFFFFF8, pacc:=0
			, NumPut(idObject==0xFFFFFFF0?0x0000000000020400:0x11CF3C3D618736E0, IID, "Int64")
			, NumPut(idObject==0xFFFFFFF0?0x46000000000000C0:0x719B3800AA000C81, IID, 8, "Int64")
			If (DllCall("oleacc\AccessibleObjectFromWindow", "Ptr",Hwnd:=WinExist("A"), "UInt",idObject, "Ptr",&IID, "Ptr*",pacc)=0){
				Acc:=ComObject(9,pacc,1), ObjAddRef(pacc)
				Try Acc.accLocation(ComObj(0x4003,&x:=0), ComObj(0x4003,&y:=0), ComObj(0x4003,&w:=0), ComObj(0x4003,&h:=0), ChildId:=0)
				, CaretX:=NumGet(x,0,"int"), CaretY:=NumGet(y,0,"int"), CaretH:=NumGet(h,0,"int")
			}
		}
		If (Caretx=0&&Carety=0){
			MouseGetPos, x, y, Hwnd
			Return {x:x,y:y,h:30,t:"Mouse",Hwnd:Hwnd}
		} Else
			Return {x:Caretx,y:Carety,h:Max(Careth,30),t:"Acc",Hwnd:Hwnd}
	} Else
		Return {x:A_CaretX,y:A_CaretY,h:30,t:"Caret",Hwnd:Hwnd}
}

; 复制对象
CopyObj(obj){
	If !IsObject(obj){
		retObj:=obj
	} Else {
		retObj := {}
		For k, v In obj
			retObj[k] := CopyObj(v)
	}
	Return retObj
}

OutputDebug(info,type){
	static buffer:=""
	Switch type
	{
		Case 1:
			FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
			FileAppend, % Now "`n" info "`n", debug.log, UTF-8
		Case 2:
			OutputDebug % info
		Case 3:
			MsgBox, 16, 错误, % StrReplace(info, "|", "`n")
		Case 4:
			buffer .= info "    "
			SetTimer, writeintolog, -1000
		Default:
			Return
	}
	Return
	writeintolog:
		FormatTime, Now, , [yyyy-MM-dd HH:mm:ss]
		FileAppend, % Now "`n" buffer "`n", debug.log, UTF-8
		; OutputDebug % buffer
		buffer:=""
	Return
}