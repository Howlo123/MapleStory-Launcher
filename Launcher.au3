#cs ----------------------------------------------------------------------------

 AutoIt Version: 1.01
 Author:         Ethan

 Script Function:
	偵測目錄、判斷網路狀態、自動更新 HShield 版本，待增自動更新。

#ce ----------------------------------------------------------------------------

#NoTrayIcon
#RequireAdmin
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <ColorConstants.au3>
#include <MsgBoxConstants.au3>
#include <Misc.au3>

; 定義變數常數
Dim Const $Version = 1.01
Dim $IPAddress,$GetData,$GUI,$Label1,$Button1,$Gamepath,$Port,$HShield_GUI,$HShield_Progress,$HShield_URL,$HShield_Label2,$HShield_Label3

$IPAddress = "104.199.253.6"
$Port = 8484
$GetData = "https://lmly9193.github.io/MapleStory-Launcher/Data"
$HShield_URL = "https://lmly9193.github.io/MapleStory-Launcher/HShield.exe"

;僅允許一個視窗執行
_Singleton("Launcher")
_Singleton("HShieldUpdate")

If FileExists("MapleStory.exe") = 0 Then
  MsgBox($MB_ICONINFORMATION,"注意","錯誤的遊戲目錄")
Else
  If Internet_Check() Then
    MsgBox($MB_ICONINFORMATION,"注意","請確認網路狀態")
  Else
    If FileExists("HShield.ver") = 0 Then
      If InetGetSize($HShield_URL) = 0 Then
        MsgBox($MB_ICONINFORMATION,"注意","無法取得更新檔案")
      Else
        HShieldGUI()
      EndIf
    ;ElseIf <expression> Then
    Else
      GUI()
    EndIf
  EndIf
EndIf

; 主介面控制函數
Func GUI()
  $GUI = GUICreate("Launcher",700,400,-1,-1,BitOR($WS_CAPTION,$WS_SYSMENU))

  GUISetBkColor($COLOR_WHITE)
  GUICtrlSetDefBkColor($COLOR_WHITE)

  $Group1 = GUICtrlCreateGroup("更新內容",10,10,500,330)
    $Edit1 = GUICtrlCreateEdit("等待載入...",20,30,480,300,BitOR($WS_VSCROLL,$ES_READONLY))

  $Group2 = GUICtrlCreateGroup("伺服器狀態",520,10,170,50)
    $Label1 = GUICtrlCreateLabel("未檢測",530,30,150,20,$SS_CENTER)

  $Group3 = GUICtrlCreateGroup("公告",520,70,170,120)
    $Label2 = GUICtrlCreateLabel(StringFormat("。禁止使用外掛\r\n\n。相容性請設定 Windows 7\r\n\n。本程式會自動載入滑鼠修復工具，關閉遊戲時請等待滑鼠修畢再離開。"),530,90,150,90)

  $Group4 = GUICtrlCreateGroup("倍率",520,200,170,70)
    $Label3 = GUICtrlCreateLabel(StringFormat("經驗 3 倍\r\n掉寶 2 倍\r\n金錢 2 倍"),530,220,150,40,$SS_CENTER)

  $Group5 = GUICtrlCreateGroup("版本",520,280,170,60)
    $Label4 = GUICtrlCreateLabel("Client TMS v1.13"&@CRLF&"Launcher v"&$Version,530,300,150,30,$SS_CENTER)

  $Button1 = GUICtrlCreateButton("開始遊戲!",0,350,700,50)

  GUISetState(@SW_SHOW,$GUI)

  GUICtrlSetData($Edit1,GetData())
  GUICtrlSetData($Label1,ServerStatus())

  While 1
    $Msg = GUIGetMsg()
      Switch $Msg
        Case $GUI_EVENT_CLOSE
          Exit
        Case $Button1
          Gamestart()
      EndSwitch
  Wend
EndFunc

; 更新介面控制函數
Func HShieldGUI()
  $HShield_GUI = GUICreate("HShieldUpdate",320,80,-1,-1,BitOR($WS_CAPTION,$WS_POPUP))

  GUISetBkColor($COLOR_WHITE)
  GUICtrlSetDefBkColor($COLOR_WHITE)

  $HShield_Label1 = GUICtrlCreateLabel("下載進度",10,20)
  $HShield_Label2 = GUICtrlCreateLabel("0 %",280,20,40)
  $HShield_Label3 = GUICtrlCreateLabel("",0,50,320,20,$SS_CENTER)
  $HShield_Progress = GUICtrlCreateProgress(70,15,200,20)

  GUISetState(@SW_SHOW,$HShield_GUI)

  HShieldDownload()
EndFunc

; 執行遊戲函數
Func Gamestart()
  $LoginAddress = $IPAddress&" "&$Port

  GUICtrlSetData($Button1,"遊戲愉快...")
  GUICtrlSetState($Button1,$GUI_DISABLE)
  Sleep(1000)

  ShellExecute("MapleStory.exe",$LoginAddress)
  GUISetState(@SW_HIDE,$GUI)

  WinWaitActive("MapleStory")
  WinClose("MapleStory")
  WinWaitActive("MapleStory")
  WinWaitClose("MapleStory")

  GUISetState(@SW_SHOW,$GUI)

  FileInstall("mousefix.exe",@TempDir&"\mousefix.exe")
  ShellExecute(@TempDir&"\mousefix.exe","",@TempDir,"",@SW_HIDE)
  MsgBox($MB_ICONINFORMATION,"修復中",StringFormat("請確認滑鼠回復正常後再關閉此視窗。"))

  ProcessClose("MapleStory.exe")
  ProcessClose("ASPLnchr.exe")
  ProcessClose("aostray.exe")
  ProcessClose("mousefix.exe")

  FileDelete(@TempDir&"\mousefix.exe")

  GUICtrlSetState($Button1,$GUI_ENABLE)
  GUICtrlSetData($Button1,"開始遊戲!")

EndFunc

; 版本內容函數
Func GetData()
  Return BinaryToString(InetRead($GetData,3),4)
EndFunc

; 伺服器狀態函數
Func ServerStatus()
  TCPStartup()
  $iSocket = TCPConnect($IPAddress,$Port)

  If @error Then
    $iError = @error
      GUICtrlSetColor($Label1,$COLOR_RED)
      GUICtrlSetState($Button1,$GUI_DISABLE)
      Switch $iError
        Case -2
          Return "維修中"
        Case 1
          Return "維修中"
        Case 2
          Return "維修中"
        Case 10060
          Return "關閉"
      EndSwitch
  Else
    GUICtrlSetColor($Label1,$COLOR_GREEN)
    Return "正常"
  EndIf

  TCPCloseSocket($iSocket)
  TCPShutdown()
EndFunc

; HShield 下載函數
Func HShieldDownload()
  $TotalSize = InetGetSize($HShield_URL,3)
  If $TotalSize > 0 Then
    $hDownload = InetGet($HShield_URL,"HShield.exe",3,1)
    Do
      Sleep(50)
      $NowDownload = InetGetInfo($hDownload,0)
      $per = Int($NowDownload/$TotalSize*100)
      $res = Int(StringLeft($per,3))
      GUICtrlSetData($HShield_Progress,$res)
      GUICtrlSetData($HShield_Label2,$res&" %")
      GUICtrlSetData($HShield_Label3,Int($NowDownload/1048576)&" MB / "&Int($TotalSize/1048576)&" MB")
    Until InetGetInfo($hDownload,2)
    Sleep(1000)
    If FileGetSize("HShield.exe") = $TotalSize Then
      HShieldUpdate()
      GUISetState(@SW_HIDE,$HShield_GUI)
      GUI()
    EndIf
  Else
    MsgBox($MB_ICONINFORMATION,"錯誤","下載失敗。請下載手動更新")
  EndIf
  Exit
EndFunc

; HShield 更新函數
Func HShieldUpdate()
  ShellExecute("HShield.exe")
  ProcessWait("HShield.exe")
  ProcessWaitClose("HShield.exe")
  FileDelete("HShield.exe")
EndFunc

; 檢查網路函數
Func Internet_Check()
  Ping("8.8.8.8",500)
  If @error Then
    Return @error
  EndIf
EndFunc