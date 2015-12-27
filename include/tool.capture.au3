#include-once <GUIConstants.au3>
#include-once <GuiEdit.au3>
#include <ScreenCapture.au3>
#Include <WinAPIEx.au3>
#include-once <string.au3>


HotKeySet ( "!s", "Capture_tool_ShowSelectedArea1" )
HotKeySet ( "!c", "Capture_tool_CaptureImage" )
HotKeySet ( "!m", "Capture_tool_GetMousePoint" )
HotKeySet ( "!p", "Capture_tool_GetPixelColor" )
HotKeySet ( "!w", "Capture_tool_win_size" )
HotKeySet ( "!a", "Capture_tool_assign_win" )
HotKeySet ( "!k", "Capture_tool_WinKill" )


Global $hSelection_GUI_1
Global $INI_FILE = "conf.ini" ;файл конфигурации
Global $ToolName = "Automation_Tools_v0.1"
Global $CaptureHelp = @CR & "Список горячих клавиш: " _
			   & @CR & "ALT+s: показать/скрыть область для захвата изображения" _
			   & @CR & "ALT+с: сохранение выделенной области в файл" _
			   & @CR & "ALT+m: определение координат мыши" _
			   & @CR & "ALT+p: определение цвета пикселя под указателем мыши" _
			   & @CR & "ALT+w: определение положения и размеров окна" _
			   & @CR & "ALT+k: принудительное закрытие окна (рабочего или текущего)" _
			   & @CR & "ALT+a: назначить активное окно рабочим"
 
;скриншот выделенной области экрана и запись его в файл			   
Func Capture_tool_CaptureImage()
   Local $pos = WinGetPos($ToolName & "area_1")
   If @error = 1 Then
	  Return
   EndIf
   Local $capture_left = $pos[0]
   Local $capture_top = $pos[1]
   Local $capture_right = $pos[0] + $pos[2]
   Local $capture_bottom = $pos[1] + $pos[3]
   Local $ImgCartureDir = IniRead($INI_FILE,"capture_image", "capture_dir", "img") & "/"
   Capture_tool_HideSelectedArea()
   Local $name = InputBox($ToolName,"Имя файла: ")
   If @error = 1 Then
	  Capture_tool_ShowSelectedArea1()
	  Return
   EndIf
   Local $capture_image_format = IniRead($INI_FILE,"capture_image", "image_format", "bmp")
   Local $filename = $name & "." & $capture_image_format
   _ScreenCapture_Capture($ImgCartureDir & $filename,$capture_left,$capture_top,$capture_right,$capture_bottom)
   MsgBox(0,$ToolName, $filename & " был создан")
EndFunc

;отображение/скрытие области выделения
Func Capture_tool_ShowSelectedArea1()
	If Not WinExists($ToolName & "area_1") Then
		Local $width = IniRead($INI_FILE,"capture_image", "width", 800)
		Local $height = IniRead($INI_FILE,"capture_image", "height", 600)
		Local $left = IniRead($INI_FILE,"capture_image", "left", 0)
		Local $top = IniRead($INI_FILE,"capture_image", "top", 0)
		Local $capture_area1_bgcolor = IniRead($INI_FILE,"capture_image", "bgcolor1", 0xFFFFFF)
		Local $capture_area_opacity = IniRead($INI_FILE,"capture_image", "opacity", 30)
	  $hSelection_GUI_1 = GUICreate($ToolName & "area_1", $width, $height, $left, $top, _
		   BitOR($WS_SIZEBOX, $WS_POPUP), BitOR( $WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
		GUISetBkColor($capture_area1_bgcolor)
		WinSetTrans($hSelection_GUI_1, "", $capture_area_opacity)
		GUISetState(@SW_SHOW)
	Else
		Capture_tool_HideSelectedArea()
	EndIf
 EndFunc

 ;скрытие области выделения
Func Capture_tool_HideSelectedArea()
   Local $pos
   If WinExists($ToolName & "area_1") Then
	  Capture_tool_SaveAreaPos()
	  GUIDelete()
   EndIf
EndFunc

;сохранение в файле настроек позиции и размеров окна
Func Capture_tool_SaveAreaPos()
   Local $pos, $size
   If WinExists($ToolName & "area_1") Then
	  $pos = WinGetPos($ToolName & "area_1")
	  $size = WinGetClientSize($ToolName & "area_1")
	  IniWrite($INI_FILE,"capture_image", "left", $pos[0])
	  IniWrite($INI_FILE,"capture_image", "top", $pos[1])
	  IniWrite($INI_FILE,"capture_image", "width", $size[0])
	  IniWrite($INI_FILE,"capture_image", "height", $size[1])
   EndIf
EndFunc

;получение кординат указателя мыши и помещение кода для клика в буфер обмена
Func Capture_tool_GetMousePoint()
	Local $mouse, $margin[2], $stringPos
	Local $mouse_coord_mode = IniRead($INI_FILE,"capture_image", "MouseCoordMode", 2)
	AutoItSetOption ( "MouseCoordMode", $mouse_coord_mode )
	$mouse = MouseGetPos()
	$stringPos = "MouseClick('left',"& $mouse[0] & "," & $mouse[1] & ",3)"
	ClipPut($stringPos)
	MsgBox(0, $ToolName, "Код для клика мыши в точке " & $mouse[0] & "," & $mouse[1] & " помещен в буфер обмена")
   
EndFunc

;получение цвета пикселя под указателем мыши и помещение в буфер обмена кода для поиска этого пикеля
Func Capture_tool_GetPixelColor()
	Local $mouse,$color,$outputString, $pos, $left, $top, $right, $bottom
	Local $mouse_coord_mode = IniRead($INI_FILE,"capture_image", "MouseCoordMode", 2)
	Local $pixel_coord_mode = IniRead($INI_FILE,"capture_image", "PixelCoordMode", 2)
	Local $win_name = IniRead($INI_FILE,"capture_image", "win_name", WinGetTitle(""))
	AutoItSetOption ( "PixelCoordMode", $mouse_coord_mode )
	AutoItSetOption ( "MouseCoordMode", $mouse_coord_mode )
	$mouse = MouseGetPos()
	If WinExists($win_name) And WinActive($win_name) Then
		$pos = WinGetPos($win_name)
		$left = $pos[0]
		$top = $pos[1]
		$right = $pos[0] + $pos[2]
		$bottom = $pos[1] + $pos[3]
		GUIDelete()
		GUIDelete()
		$color = PixelGetColor ( $mouse[0] , $mouse[1] )
		$outputString = "PixelSearch ( " & $left & "," & $top & "," & $right & "," & $bottom & ",0x" & Hex($color,6) & ")"
	ElseIf WinExists($ToolName & "area_1") Then
		$pos = WinGetPos($ToolName & "area_1")
		$left = $pos[0]
		$top = $pos[1]
		$right = $pos[0] + $pos[2]
		$bottom = $pos[1] + $pos[3]
		GUIDelete()
		GUIDelete()
		$color = PixelGetColor ( $mouse[0] , $mouse[1] )
		$outputString = "PixelSearch ( " & $left & "," & $top & "," & $right & "," & $bottom & ",0x" & Hex($color,6) & ")"
	Else
		$left = 0
		$top = 0
		$right = "@DesktopWidth"
		$bottom = "@DesktopHeight"
		$color = PixelGetColor ( $mouse[0] , $mouse[1] )
		$outputString = "PixelSearch ( " & $left & "," & $top & "," & $right & "," & $bottom & ",0x" & Hex($color,6) & ")"
	EndIf
	ClipPut($outputString)
	MsgBox(0,$ToolName,"Код " & Hex($color,6) & " для поиска пикселя помещен в буфер обмена")
EndFunc

;получение позиции и размера рабочего или активного окна или выделенной области
; и помещение в буфер обмена кода для перемещения окна 
Func Capture_tool_win_size()
	Local $size
	Local $title
	Local $win_name = IniRead($INI_FILE,"capture_image", "win_name", WinGetTitle(""))
	If WinExists($win_name) Then
		$size = WinGetPos($win_name)
		$title = $win_name
	Else
		If WinExists($ToolName & "area_1") Then
			$size = WinGetPos($ToolName & "area_1")
			$title = "Выделенная область"
		Else
			$size = WinGetPos("")
			$title = WinGetTitle("")
		EndIf	
	EndIf
	
	$stringForClipboard = "WinMove('" & $title & "', ''," & $size[0] & "," & $size[1] & "," & $size[2] & "," & $size[3] & ")"
	ClipPut($stringForClipboard)
	MsgBox(0, $ToolName, "Window: '" & $title & "'" & @CR & _
									"положение и размер " & @CR & _
									"x: " & $size[0] & @CR & _
									"y: " & $size[1] & @CR & _
									"size: " & $size[2] & " x " & $size[3])
EndFunc

;назначение активного окна рабочим
Func Capture_tool_assign_win()
	$win_title = WinGetTitle("")
	Local $answer = MsgBox(1, $ToolName, "Установить рабочим окно: '" & $win_title & "'?")
	If $answer == 1 Then
		IniWrite($INI_FILE,"capture_image", "win_name", $win_title)
	EndIf
EndFunc

;принудительное закрытие окна
Func Capture_tool_WinKill()
	Local $win_name = IniRead($INI_FILE,"capture_image", "win_name", WinGetTitle(""))
	Local $answer = MsgBox(1, $ToolName, "Закрыть окно принудительно?: '" & $win_name & "'?")
	If $answer == 1 Then
		WinKill($win_name)
	EndIf
EndFunc
