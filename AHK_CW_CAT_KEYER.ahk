
SetWorkingDir %A_ScriptDir% 

; simple CW CAT KEYER v. 1.0
; by  www.radiohotkey.pl
; CAT Command - FTDX 3000
; more: https://www.radiohotkey.pl/index.php/cw-cat-memory-keyer/

; SerialSend.exe download from
; https://batchloaf.wordpress.com/serialsend/ 
; and put in the same directory on the disk as the presented script

; enter your data in the keyer.ini file

IniRead, port, keyer.ini, setup, port   
IniRead, br, keyer.ini, setup, br 		
IniRead, title, keyer.ini, setup, title 

IniRead, wpm1, keyer.ini, setup, wpm1 
IniRead, wpm2, keyer.ini, setup, wpm2
IniRead, wpm3, keyer.ini, setup, wpm3

IniRead, key_weight1, keyer.ini, setup, key_weight1 
IniRead, key_weight2, keyer.ini, setup, key_weight2
IniRead, key_weight3, keyer.ini, setup, key_weight3


wpm := wpm2
key_weight := key_weight2


;--- GUI -------------------------------------------------------------------------------

Gui, 1:-MaximizeBox
Gui, 1:Color, AACCCC 

; section CW MEMO
Gui, 1:Font,  s8  cBlack 
Gui, 1:Add,   GroupBox, x10 y25 w480 h70 c333333, CW Memo [ Ctrl+Click : change memo ]
Gui, 1:Font,  s12  cBlack 
Gui, 1:Add, Button, x60   y50 w45 h30 gMEMO1, M1
Gui, 1:Add, Button, xp+45 yp  w45 h30 gMEMO2, M2
Gui, 1:Add, Button, xp+45 yp  w45 h30 gMEMO3, M3
Gui, 1:Add, Button, xp+45 yp  w45 h30 gMEMO4, M4
Gui, 1:Add, Button, xp+45 yp  w45 h30 gMEMO5, M5

Gui, 1:Add, Button, x370  yp  w70 h30 gSTOPkey, STOP

; section WPM
Gui, 1:Font,  s8  cBlack 
Gui, 1:Add,   GroupBox, x10 y95 w300 h60 c333333, WPM
Gui, 1:Font,  s12 cBlack 
Gui, 1:Add, Button, x60   y115 w50 h30 gSPEED1, %wpm1%
Gui, 1:Add, Button, xp+60 yp   w50 h30 gSPEED2, %wpm2%
Gui, 1:Add, Button, xp+60 yp   w50 h30 gSPEED3, %wpm3%

; section Weight
Gui, 1:Font,  s8  cBlack 
Gui, 1:Add,   GroupBox, x10 y155 w300 h60 c333333, Weight
Gui, 1:Font,  s12 cBlack 
Gui, 1:Add, Button, x60   y175 w50 h30 gWEIGHT1, 1:%key_weight1%
Gui, 1:Add, Button, xp+60 yp w50   h30 gWEIGHT2, 1:%key_weight2%
Gui, 1:Add, Button, xp+60 yp w50   h30 gWEIGHT3, 1:%key_weight3%

; UTC TIME
Gui, 1:Font,  s16 cBlack Bold
Gui, 1:Add, Text, x360 y175 w80 c000000 Center BackgroundTrans vDUTC, 00:00:00 
Gui, 1:Font,  s8 cBlack Bold
Gui, 1:Add, Text, x455 y175 w80 c555555 Left BackgroundTrans , UTC

; start GUI
Gui  1:Show,x500 y500 w500 h235, %title% wpm=%wpm% weight=1:%key_weight%
MsgBox Set CW mode in TRX :-)

; start timer
SetTimer, TimerProcedure, 250

Return

; Procedures ------------------------------------------------------------------------------------

; Procedure for sending any string of characters to the serial port
; using SerialSend.exe:

 Sendserial(cport, brate, vstr)
    {
      RunWait %ComSpec% /c serialsend.exe /devnum %cport% /baudrate %brate% "%vstr%",,Hide
	  Return
    }

; alternative version of the procedure using Windows commands:

; Sendserial(cport, brate, vstr)
;	{
;	  RunWait, %ComSpec% /c mode COM%cport% BAUD=%brate% PARITY=n DATA=8,,Hide
;	  RunWait, %ComSpec% /c SET /p x="%vstr%" <nul >\\.\COM%cport%,,Hide
;     Return
;	}


; Set window title 

 SetTitle(title, w, k)
	{
	  WinSetTitle, %title% wpm=%w% weight=1:%k%
	  Return
	}

; Procedure for sending text to radio and starting CW
; CAT commands used: KM and KY

 Sendmemo(cport, brate, nr)
	{
	 IniRead, tekst, keyer.ini, bank, m%nr%
	 CATstring := "KM5" . tekst . "};KYA;"
	 Sendserial(cport, brate, CATstring)
	 Return
	}

; Set CW Speed
; CAT:  KS

 Setspeed(cport, brate, vspeed)
	{
	 ;global port, br
	 CATstring := "KS0" . Format("{:02}", vspeed) . ";"
	 Sendserial(cport, brate, CATstring)
	 Return
	}

; Procedure for changing the dot to dash ratio 
; CAT:  EX022  (Menu , position 22)

Setweight(cport, brate, vweight)
	{
	 ;global port, br
	 CATstring := "EX022" . Floor(vweight*10) . ";"
	 Sendserial(cport, brate, CATstring)
	 Return
	}

; Set memo

SetMemo(nr)
{
	IniRead, tekst, keyer.ini, bank, m%nr%
	InputBox, dane, Memo, Set memo nr %nr%, ,300 ,170 , , , , , % tekst
	If !Errorlevel
	  IniWrite, %dane%, keyer.ini, bank, m%nr%
	Return
}

; ------ Keyboard and keys -------------------------------------------

!1::    
MEMO1:
	if GetKeyState("Control")
	 SetMemo(1)
	else 
	 Sendmemo(port, br, 1)
Return

!2::
MEMO2:
	if GetKeyState("Control") 
	 SetMemo(2)
    else 
	 Sendmemo(port, br, 2)
Return

!3::
MEMO3:
	if GetKeyState("Control")
	 SetMemo(3)
	else 
	 Sendmemo(port, br, 3)
Return

!4::
MEMO4:
	if GetKeyState("Control")
	 SetMemo(4)
	else 
	 Sendmemo(port, br, 4)
Return

!5::
MEMO5:
	if GetKeyState("Control")
	 SetMemo(5)
	else 
	 Sendmemo(port, br, 5)
Return


SPEED1:
	wpm := wpm1
	SetTitle(title, wpm, key_weight)
	Setspeed(port, br, wpm)
Return

SPEED2:
	wpm := wpm2
	SetTitle(title, wpm, key_weight)
	Setspeed(port, br, wpm)
Return

SPEED3:
	wpm := wpm3
	SetTitle(title, wpm, key_weight)
	Setspeed(port, br, wpm)
Return

!ESC::
STOPkey:
	global port, br
	CATstring := "KM5 };KYA;"
	Sendserial(port, br, CATstring)
Return

WEIGHT1:
	key_weight := key_weight1
	SetTitle(title, wpm, key_weight)
	Setweight(port, br, key_weight)
Return

WEIGHT2:
	key_weight := key_weight2
	SetTitle(title, wpm, key_weight)
	Setweight(port, br, key_weight)
Return

WEIGHT3:
	key_weight := key_weight3
	SetTitle(title, wpm, key_weight)
	Setweight(port, br, key_weight)
Return

; Timer procedure
; UTC Time
; keyer memory preview
 
TimerProcedure:
 
  gutc := SubStr(A_NowUTC,9,2) . ":" . SubStr(A_NowUTC,11,2) . ":" . A_Sec
  GuiControl ,1:Text, DUTC, %gutc%   

 ;simple OnMouseOver:
  MouseGetPos,,,okno,kontrolka
  ControlGetText,opis,%kontrolka%,ahk_id %okno%
  if opis IN M1,M2,M3,M4,M5
    {
		nr := SubStr(opis,2)
		IniRead, tekst, keyer.ini, bank, m%nr%
		tooltip, %tekst%
	}
	  else 
	{
		tooltip,
	}
Return  ;Timerprocedure

GuiClose:
ExitApp

!r::Reload
