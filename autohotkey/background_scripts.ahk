#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Map Shift+Capslock to Capslock and Capslock to Ctrl
+Capslock::Capslock
Capslock::Ctrl

; ======================================= ;

; Map right Alt to Enter, and disable Enter
RAlt::Enter
Enter::Return
