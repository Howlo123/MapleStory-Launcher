#NoTrayIcon
#RequireAdmin
#include <MsgBoxConstants.au3>

If FileExists("MapleStory.exe") = 0 Then
	MsgBox($MB_ICONINFORMATION, "Error", "Please put the file in the game directory")
Else
	FileInstall("mousefix.exe", @TempDir & "\mousefix.exe")
	Run("MapleStory.exe 104.199.151.150 8484")
	WinWaitActive("MapleStory")
	WinClose("MapleStory")
	WinWaitActive("MapleStory")
	WinWaitClose("MapleStory")
	ProcessClose("MapleStory.exe")
	ProcessClose("ASPLnchr.exe")
	Run(@TempDir & "\mousefix.exe", @TempDir);@SW_HIDE
	;FileDelete(@TempDir & "\mousefix.exe")
EndIf