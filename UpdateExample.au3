#include <GUIConstants.au3>
#include <Misc.au3>
Opt ("GUIOnEventMode", 1)

Dim $Title = "AutoUpdata"
Dim $FilePath_Server = "http://xxxxxxxxxxx";;���A���s�ɮ�
Dim $FilePath_Local = "R:\run.exe" ;;�ݭn��s�{�������|

_Singleton ($Title);;�Ȥ��\�{����W����

;~ _Check();;�e�m�ˬd�@�~

GUICreate ( $Title, 280, 80)

GUICtrlCreateLabel ("��s�i��", 10, 20)

$Progres = GUICtrlCreateProgress ( 70, 15, 200, 20)
GUICtrlCreateButton ("�}�l��s", 70, 50, 60, 20)
  GUICtrlSetOnEvent ( -1, "_Start")
GUICtrlCreateButton ( "���}", 150, 50, 60, 20)
  GUICtrlSetOnEvent ( -1, "_Exit")

GUISetState ()

While True
  Sleep (50)
WEnd

Func _Exit()
  Exit
EndFunc

Func _Start()
  $TotalSize = InetGetSize ($FilePath_Server) ;; ���o�`�e�q
  $hDownload = InetGet ($FilePath_Server, $FilePath_Local, 1, 1) ;;�}�l�U��

  Do
    Sleep (50)
    $NowDownload = InetGetInfo($hDownload, 0)

    $per = Int ($NowDownload/$TotalSize*100) ;;�p��ʤ���
    $res = Int (StringLeft ( $per, 3)) ;;�ʤ���
    GUICtrlSetData ($progres , $res) ;;�U���i��

    TrayTip ( "���b�U����s��", "�w�U�� " & ($NowDownload/1024)&" kB", 1) ;;�ʵ��w�U���j�p

  Until InetGetInfo ( $hDownload, 2)

  GuiCtrlSetData ( $progres , 0)

  If $TotalSize = FileGetSize ($FilePath_Local) Then
    MsgBox ( 0, "��s����", "�ɮפj�p�G" &Int ($TotalSize/1024)&" kB"&@CRLF&"�w�U���j�p�G" & Int ($NowDownload/1024)&" kB")
    Run($FilePath_Local) ;;����{��
    Exit
  Else
    MsgBox ( 16, "���~", "��s���ѡC")
  EndIf

EndFunc

Func _Check()
  $Ping = Ping ( "8.8.8.8", 500) ;;;�ˬd�����O�_�q�Z

  If $Ping Then
    TrayTip ( "�۰ʧ�s�{��", "���b�ˬd�ɮ�...", 2)
  Else
    MsgBox ( 16, "ĵ�i", "�����s�����ѡA�еy��A���աC")
    Exit
  EndIf

  $FileSize_Server = InetGetSize ($FilePath_Server);;���o���A���s�ɮת��j�p
  If @error Then
    MsgBox ( 36, "ĵ�i", "�L�k���o���A���T���A")
    Exit
  EndIf

  $FileSize_Local = FileGetSize ("run.exe");;���o�����ɮפj�p
  If @error Then
    If MsgBox ( 36, "ĵ�i", "�L�k���o�ɮ׸�T�A�O�_�~��U���C") = 7 Then Exit
  EndIf

  If $FileSize_Server = $FileSize_Local Then
      MsgBox( 0, "����", "�ɮ��ˬd����"&@CRLF&"�ثe�w���̷s���C")
      Exit
  EndIf
EndFunc