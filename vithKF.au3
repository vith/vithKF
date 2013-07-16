; some useful functions for Killing Floor
; - borderless windowed mode
; - crosshair overlay (only works in windowed mode)
; - gamma (OS level setting that works on windowed mode)



#NoTrayIcon

#include <WinAPI.au3>
#include <Constants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>
#include <GDIPlus.au3>



;; globals

$crosshairHandle = False
$title = "[CLASS:KillingFloorUnrealWWindowsViewportWindow]"
$settingsDir = @AppDataDir & "\vithKF\"
$settingsFile = $settingsDir & "settings.ini"



;; main GUI setup

$vithKF = GUICreate("vithKF", 200, 100, -1, -1, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX))
$removeBorderCtrl = GUICtrlCreateCheckbox("Remove window border", 10, 10)
$fullscreenCtrl = GUICtrlCreateCheckbox("Make window fullscreen", 10, 30)
$crosshairCtrl = GUICtrlCreateCheckbox("Draw crosshair", 10, 50)
$gammaEnabledCtrl = GUICtrlCreateCheckbox("Adjust screen gamma", 10, 70)
$gammaValueCtrl = GUICtrlCreateSlider(140, 70, 50, 21)
GUICtrlSetLimit($gammaValueCtrl, 386, 0)
If IniRead($settingsFile, "Settings", "removeBorder", "False") == "True" Then
   GUICtrlSetState($removeBorderCtrl, $GUI_CHECKED)
EndIf
If IniRead($settingsFile, "Settings", "fullscreen", "False") == "True" Then
   GUICtrlSetState($fullscreenCtrl, $GUI_CHECKED)
EndIf
If IniRead($settingsFile, "Settings", "crosshair", "False") == "True" Then
   GUICtrlSetState($crosshairCtrl, $GUI_CHECKED)
EndIf
If IniRead($settingsFile, "Settings", "gammaEnabled", "False") == "True" Then
   GUICtrlSetState($gammaEnabledCtrl, $GUI_CHECKED)
   GUICtrlSetState($gammaValueCtrl, $GUI_ENABLE)
Else
   GUICtrlSetState($gammaValueCtrl, $GUI_DISABLE)
EndIf
GUICtrlSetData($gammaValueCtrl, IniRead($settingsFile, "Settings", "gammaValue", 224))
GUISetState(@SW_SHOW, $vithKF)



;; utility functions

Func IsChecked($ctrl)
   Return BitAND(GUICtrlRead($ctrl), $GUI_CHECKED) > 0
EndFunc

Func SaveSetting($setting, $value)
   If NOT FileExists($settingsDir) Then
	  DirCreate($settingsDir)
   EndIf
   IniWrite($settingsFile, "Settings", $setting, $value)
EndFunc

Func ReadSetting($setting)
   If FileExists($settingsFile) Then
	  IniRead($settingsFile, "Settings", $setting, "False")
   EndIf
EndFunc

Func _SetGamma ( $vRed=128, $vGreen=128, $vBlue=128 )
   ; _SetGamma function taken from http://superuser.com/a/383481
    Local $n_ramp, $rVar, $gVar, $bVar, $Ret, $i, $dc
    If $vRed < 0 Or $vRed > 386 Then Return -1
    If $vGreen < 0 Or $vGreen > 386 Then Return -1
    If $vBlue < 0 Or $vBlue > 386 Then Return -1
    $dc = DLLCall ( "user32.dll", "int", "GetDC","hwnd", 0 )
    $n_ramp = DllStructCreate ( "short[" & ( 256*3 ) & "]" )
    For $i = 1 to 256
	   $rVar = $i * ( $vRed + 128 )
	   If $rVar > 65535 Then $rVar = 65535
	   $gVar = $i * ( $vGreen + 128 )
	   If $gVar > 65535 Then $gVar = 65535
	   $bVar = $i * ( $vBlue + 128 )
	   If $bVar > 65535 Then $bVar = 65535
	   DllStructSetData ( $n_ramp, 1, Int ( $rVar ), $i  ) ; red
	   DllStructSetData ( $n_ramp, 1, Int ( $gVar ), $i+256 ) ; green
	   DllStructSetData ( $n_ramp, 1, Int ( $bVar ), $i+512 ) ; blue
	Next
    $ret = DLLCall ( "gdi32.dll", "int", "SetDeviceGammaRamp", "int", $dc[0], "ptr", DllStructGetPtr ( $n_Ramp ) )
    $dc = 0
    $n_Ramp = 0
 EndFunc
 
Func SetGamma($gamma)
   _SetGamma($gamma, $gamma, $gamma)
EndFunc

Func applyGamma()
   If IsChecked($gammaEnabledCtrl) Then
	  SetGamma(GUICtrlRead($gammaValueCtrl))
   Else
	  SetGamma(128)
   EndIf
EndFunc

Func BitANDNOT($a, $b)
   Return BitAND($a, BitNOT($b))
EndFunc

Func applyBorder()
   If IsChecked($removeBorderCtrl) AND WinExists($title) Then
	  $handle = WinGetHandle($title)
	  $style = _WinAPI_GetWindowLong($handle, $GWL_STYLE)
	  If BitAND($style, $WS_CAPTION) > 0 Then
		 $new_style = BitANDNOT($style, $WS_CAPTION)
		 _WinAPI_SetWindowLong($handle, $GWL_STYLE, $new_style)
		 ConsoleWrite("Removed window caption." & @CRLF)
		 Sleep(250)
	  EndIf
	  $style = _WinAPI_GetWindowLong($handle, $GWL_STYLE)
	  If BitAND($style, $WS_SIZEBOX) > 0 Then
		 $new_style = BitANDNOT($style, $WS_SIZEBOX)
		 _WinAPI_SetWindowLong($handle, $GWL_STYLE, $new_style)
		 ConsoleWrite("Removed window sizebox." & @CRLF)
		 Sleep(250)
	  EndIf
   EndIf
EndFunc

Func applyFullscreen()
   If IsChecked($fullscreenCtrl) AND WinExists($title) Then
	  $pos = WinGetPos($title)
	  If $pos[0] <> 0 OR $pos[1] <> 0 OR $pos[2] <> @DesktopWidth OR $pos[3] <> @DesktopHeight Then
		 WinMove($title, "", 0, 0, @DesktopWidth, @DesktopHeight)
		 $new_pos = WinGetPos($title)
		 ConsoleWrite(StringFormat("Moved window from %d,%d (%dx%d) to %d,%d (%dx%d)\n", $pos[0], $pos[1], $pos[2], $pos[3], $new_pos[0], $new_pos[1], $new_pos[2], $new_pos[3]))
	  EndIf
   EndIf
EndFunc

Func applyCrosshair()
   If IsChecked($crosshairCtrl) AND NOT $crosshairHandle Then
	  _GDIPlus_Startup()
	  $crosshair_image = _GDIPlus_ImageLoadFromFile(@WorkingDir & "\crosshair.gif")
	  $w = _GDIPlus_ImageGetWidth($crosshair_image)
	  $h = _GDIPlus_ImageGetHeight($crosshair_image)
	  _GDIPlus_ImageDispose($crosshair_image)
	  _GDIPlus_Shutdown()
	  $x = @DesktopWidth/2 - $w/2
	  $y = @DesktopHeight/2 - $h/2

	  $crosshairHandle = GUICreate("", $w, $h, $x, $y, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_TOOLWINDOW, $WS_EX_TOPMOST))
	  GUICtrlCreatePic("crosshair.gif",0,0,$w,$h)

	  _WinAPI_SetWindowLong($crosshairHandle, $GWL_EXSTYLE, BitOR(_WinAPI_GetWindowLong($crosshairHandle, $GWL_EXSTYLE), $WS_EX_TRANSPARENT))
	  GUISetState(@SW_SHOW, $crosshairHandle)
   ElseIf NOT IsChecked($crosshairCtrl) AND $crosshairHandle Then
	  GUIDelete($crosshairHandle)
	  $crosshairHandle = False
   EndIf
EndFunc



;; initialization

applyBorder()
applyFullscreen()
applyCrosshair()
applyGamma()

While 1
   Switch GUIGetMsg()
	  Case $GUI_EVENT_CLOSE
		 GUIDelete()
		 If IsChecked($gammaEnabledCtrl) Then
			setGamma(128)
		 EndIf
		 ExitLoop
	  Case $removeBorderCtrl
		 $state = IsChecked($removeBorderCtrl)
		 SaveSetting("removeBorder", $state)
		 applyBorder()
	  Case $fullscreenCtrl
		 $state = IsChecked($fullscreenCtrl)
		 SaveSetting("fullscreen", $state)
		 applyFullscreen()
	  Case $crosshairCtrl
		 $state = IsChecked($crosshairCtrl)
		 SaveSetting("crosshair", $state)
		 applyCrosshair()
	  Case $gammaEnabledCtrl
		 $state = IsChecked($gammaEnabledCtrl)
		 SaveSetting("gammaEnabled", $state)
		 If $state == True Then
			GUICtrlSetState($gammaValueCtrl, $GUI_ENABLE)
		 Else
			GUICtrlSetState($gammaValueCtrl, $GUI_DISABLE)
		 EndIf
		 applyGamma()
	  Case $gammaValueCtrl
		 $value = GUICtrlRead($gammaValueCtrl)
		 SaveSetting("gammaValue", $value)
		 applyGamma()
   EndSwitch
WEnd
