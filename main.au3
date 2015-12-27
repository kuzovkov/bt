#include <GUIConstants.au3>
#include "include/tool.capture.au3"

;############################
#NoTrayIcon

Opt("TrayMenuMode",3)   ; Default tray menu items (Script Paused/Exit) will not be shown.
TraySetIcon("Resources.ico") ;иконка
HotKeySet ( "!q", "ExitApp" )

;пункты меню
;tools
$capturehelpitem    = TrayCreateItem("Help")
;about, exit
$aboutitem      = TrayCreateItem("About")
TrayCreateItem("")
$exititem       = TrayCreateItem("Exit (alt+q)")

TraySetState()
AutoItSetOption ( "SendKeyDelay", 200 )

$About = "Инструменты для облегчения написания кода на AutoIt"


;цикл обработки событий меню
While 1
    $msg = TrayGetMsg()
    Select
        Case $msg = 0
            ContinueLoop
		 Case $msg = $capturehelpitem
			   Msgbox(64,$ToolName & ":", $CaptureHelp)
		 Case $msg = $aboutitem
			   Msgbox(64,"About:", $About)
		 Case $msg = $exititem
			   ExitLoop
    EndSelect
WEnd
Exit

Func ExitApp()
   Exit
EndFunc







