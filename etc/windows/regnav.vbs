' Created by Sergey Tkachenko
' (c) http://winaero.com/
Dim objHTA
Dim cClipBoard
Dim WshShell
set objHTA=createobject("htmlfile")
cClipBoard=objHTA.parentwindow.clipboarddata.getdata("text")
Set WshShell = WScript.CreateObject("WScript.Shell")
WshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Regedit\LastKey", cClipBoard, "REG_SZ"
WshShell.Run "regedit.exe -m"
Set objHTA = nothing
Set WshShell = nothing