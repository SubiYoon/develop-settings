#Requires AutoHotkey v2.0

; ========================
; 🌐 Global Hotkeys
; ========================

; Ctrl + C → Ctrl + Insert (복사)
^c::Send('{Ctrl down}{Insert}{Ctrl up}')

; Ctrl + V → Shift + Insert (붙여넣기)
^v::Send('{Shift down}{Insert}{Shift up}')

; Ctrl + Shift + 4 → Win + Shift + S
^+4::Send('#+s')

; ========================
; 💻 IntelliJ 전용 Hotkeys
; ========================

#HotIf WinActive("ahk_exe idea64.exe")

; Ctrl + N → Alt + Insert (Generate 메뉴)
^n::Send('{Alt down}{Insert}{Alt up}')

; IntelliJ 에서만 Ctrl + , 누르면 Ctrl + Alt + S 입력되게 설정
^,::Send('^!s')  ; Ctrl + , → Ctrl + Alt + S

; IntelliJ에서만 Ctrl + ; 누르면 Ctrl + Alt + Shift + S 전송
^;::Send('^+!s')  ; Ctrl + ; → Ctrl + Shift + Alt + S

; Ctrl + W 누르면 Ctrl + F4 보내기
^w::Send('^{F4}')

#HotIf