#NoTrayIcon
#include-once
#include <GUIConstantsEx.au3>
#include <WinAPISys.au3>
#include <WindowsConstants.au3>
#include <ColorConstants.au3>
#include <StaticConstants.au3>

$GUI = GUICreate("MapleStory",350,120,-1,-1,$WS_SYSMENU,$WS_EX_DLGMODALFRAME)
$hIcon = _WinAPI_GetClassLongEx($GUI,$GCL_HICON)
_WinAPI_DestroyIcon($hIcon)
_WinAPI_SetClassLongEx($GUI,$GCL_HICON,0)
_WinAPI_SetClassLongEx($GUI,$GCL_HICONSM,0)

Local $Label_1 = GuiCtrlCreateLabel("無法登入伺服器。" & @CRLF & "詳情查看官方網站。",-1,20,350,40,$SS_CENTER)
Local $Button_1 = GUICtrlCreateButton("&YES",80,55,80,25)
Local $Button_2 = GUICtrlCreateButton("&NO",180,55,80,25)
GUISetState(@SW_SHOW)

While 1
  $nMsg = GUIGetMsg()
  Switch $nMsg
    Case $GUI_EVENT_CLOSE
    Exit
  Case $Button_1
    ;Run ("Notepad.exe")
    ;ShellExecute("http://www.google.com")
    GUICtrlSetData($Label_1,Call("ServerStatus"))
  Case $Button_2
    Exit
  EndSwitch
WEnd

Func ServerStatus()
  TCPStartup()

  OnAutoItExitRegister("OnAutoItExit")
  Local $sIPAddress = "104.199.151.150"
  Local $iPort = 8484
  Local $iSocket = TCPConnect($sIPAddress, $iPort)
  
  If @error Then
    Local $iError = @error
      GUICtrlSetColor($Label_1, $COLOR_RED)
      Switch $iError
        Case -2
          Return "not connected."
        Case 1
          Return "IPAddr is incorrect."
        Case 2
          Return "port is incorrect."
        Case 10060
          Return "Connection timed out."
      EndSwitch
  Else
    GUICtrlSetColor($Label_1, $COLOR_GREEN)
    Return "Connection successful"
  EndIf
  
  TCPCloseSocket($iSocket)
EndFunc

Func OnAutoItExit()
  TCPShutdown()
EndFunc