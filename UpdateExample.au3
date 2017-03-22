#include <GUIConstants.au3>
#include <Misc.au3>
Opt ("GUIOnEventMode", 1)

Dim $Title = "AutoUpdata"
Dim $FilePath_Server = "http://xxxxxxxxxxx";;伺服器新檔案
Dim $FilePath_Local = "R:\run.exe" ;;需要更新程式的路徑

_Singleton ($Title);;僅允許程式單獨執行

;~ _Check();;前置檢查作業

GUICreate ( $Title, 280, 80)

GUICtrlCreateLabel ("更新進度", 10, 20)

$Progres = GUICtrlCreateProgress ( 70, 15, 200, 20)
GUICtrlCreateButton ("開始更新", 70, 50, 60, 20)
  GUICtrlSetOnEvent ( -1, "_Start")
GUICtrlCreateButton ( "離開", 150, 50, 60, 20)
  GUICtrlSetOnEvent ( -1, "_Exit")

GUISetState ()

While True
  Sleep (50)
WEnd

Func _Exit()
  Exit
EndFunc

Func _Start()
  $TotalSize = InetGetSize ($FilePath_Server) ;; 取得總容量
  $hDownload = InetGet ($FilePath_Server, $FilePath_Local, 1, 1) ;;開始下載

  Do
    Sleep (50)
    $NowDownload = InetGetInfo($hDownload, 0)

    $per = Int ($NowDownload/$TotalSize*100) ;;計算百分比
    $res = Int (StringLeft ( $per, 3)) ;;百分值
    GUICtrlSetData ($progres , $res) ;;下載進度

    TrayTip ( "正在下載更新中", "已下載 " & ($NowDownload/1024)&" kB", 1) ;;監視已下載大小

  Until InetGetInfo ( $hDownload, 2)

  GuiCtrlSetData ( $progres , 0)

  If $TotalSize = FileGetSize ($FilePath_Local) Then
    MsgBox ( 0, "更新完成", "檔案大小：" &Int ($TotalSize/1024)&" kB"&@CRLF&"已下載大小：" & Int ($NowDownload/1024)&" kB")
    Run($FilePath_Local) ;;執行程序
    Exit
  Else
    MsgBox ( 16, "錯誤", "更新失敗。")
  EndIf

EndFunc

Func _Check()
  $Ping = Ping ( "8.8.8.8", 500) ;;;檢查網路是否通暢

  If $Ping Then
    TrayTip ( "自動更新程序", "正在檢查檔案...", 2)
  Else
    MsgBox ( 16, "警告", "網路連結失敗，請稍後再嘗試。")
    Exit
  EndIf

  $FileSize_Server = InetGetSize ($FilePath_Server);;取得伺服器新檔案的大小
  If @error Then
    MsgBox ( 36, "警告", "無法取得伺服器訊息，")
    Exit
  EndIf

  $FileSize_Local = FileGetSize ("run.exe");;取得本機檔案大小
  If @error Then
    If MsgBox ( 36, "警告", "無法取得檔案資訊，是否繼續下載。") = 7 Then Exit
  EndIf

  If $FileSize_Server = $FileSize_Local Then
      MsgBox( 0, "提示", "檔案檢查完成"&@CRLF&"目前已為最新版。")
      Exit
  EndIf
EndFunc