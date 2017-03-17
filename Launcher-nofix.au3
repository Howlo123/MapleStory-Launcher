#RequireAdmin
#include <MsgBoxConstants.au3>

If FileExists("MapleStory.exe") = 0 Then
	MsgBox($MB_ICONINFORMATION, "Error", "Please put the file in the game directory")
Else
	Run("MapleStory.exe IP Port")
EndIf