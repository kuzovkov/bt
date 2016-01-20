HotKeySet ( "!t", "PSAuto_saveTemplate" )
HotKeySet ( "!d", "PsAuto_setTemplate_dir" )


Func PSAuto_saveTemplate()
Local $template_dir = IniRead($INI_FILE,"ps_auto", "template_dir", "template")
Local $res, $name, $i
Local $suffix = StringSplit("a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,r,q,s,t,v,u,x,y,w,z", ",",1)
Local $handle = WinGetHandle("[CLASS:Photoshop]")
If @error Then
    MsgBox(4096, "Error", "Please start Photoshop and open the image file")
Else
	$res = WinActivate($handle)
EndIf
If $res == 0 Then 
	Return
Else
	$name = InputBox( $ToolName, "Имя шаблона символа")
	Send("^c")
	Sleep(1000)
	Send("^n")
	For $i = 1 To 26
		$lastname = $name & $suffix[$i]
		If Not FileExists($template_dir & "\" & $lastname & ".pbm") Then
			ExitLoop
		EndIf
	Next
	Send($lastname)
	Sleep(500)
	Send("{ENTER}")
	Sleep(500)
	Send("^v")
	Sleep(500)
	Send("+^s")
	Sleep(500)
	ClipPut($template_dir & "\" & $lastname & ".pbm")
	Send("^v")
	Send("{TAB}")
	Send("{DOWN}")
	Send("{HOME}")
	For $i = 1 to 17 
		Send("{DOWN}")
	Next
	Send("{ENTER}")
	Send("{TAB}")
	Send("{ENTER}")
	Send("^w")
	Send("{TAB}")
	Send("{ENTER}")
EndIf	

EndFunc

;изменение каталога шаблонов
Func PsAuto_setTemplate_dir()
	Local $templ_dir = InputBox ( $ToolName, "Введите имя каталога шаблонов символов" )
	IniWrite($INI_FILE,"ps_auto", "template_dir", $templ_dir)
EndFunc

