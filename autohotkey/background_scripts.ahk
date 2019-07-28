#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Get the USERPROFILE value from the environment
EnvGet, USERPROFILE, USERPROFILE

; Open PowerShell with Win+Enter
#Enter::
    Run *RunAs shell:AppsFolder\Microsoft.WindowsTerminal_8wekyb3d8bbwe!App
Return

; Open Git Bash with Win+\
#\::
    Run *RunAs "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Git\Git Bash.lnk"
Return

; Open Bash for Windows with Win+Backspace
#Backspace::
    Run ubuntu
Return

; Open Clink with Win+RShift
#RShift::
    Run *RunAs "C:\Program Files (x86)\clink\0.4.8\clink.bat", %USERPROFILE%
Return

; Type ¯\_(ツ)_/¯ with Win+Capslock
#Capslock::
    SendInput, ¯\_(ツ)_/¯
Return
