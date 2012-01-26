#include "WinHttp.au3"
#include "JSON.au3"
#include "JSON_Translate.au3"
#include <File.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <TabConstants.au3>
#include <WindowsConstants.au3>
Opt("MustDeclareVars", 1)
Opt("GUIResizeMode", $GUI_DOCKALL)
Global $URL = "127.0.0.1", $PORT = "3121", $jsonver = "2.0"
Global $TextInBox, $toPost
Local $mFile = "methods.conf"
Dim $fArray
If Not _FileReadToArray($mFile, $fArray) Then
	MsgBox(4096, "Error", " Error reading " & $mFile & " to Array." & @CRLF & "error: " & @error)
	Exit
EndIf
Global $numsM = $fArray[0], $arrM[$numsM + 1][8]
For $n = 1 To $numsM
	Local $a = StringSplit($fArray[$n], ";")
	For $k = 1 To $a[0]
		$arrM[$n - 1][$k - 1] = $a[$k]
	Next
Next
GUICreate(@ScriptName, 701, 501, -1, -1)
GUICtrlSetDefBkColor(0xFFFFFF)
Global $Box = GUICtrlCreateEdit("", 5, 150, 691, 346, BitOR($ES_AUTOVSCROLL, $ES_AUTOHSCROLL, $ES_READONLY, $WS_HSCROLL, $WS_VSCROLL, $WS_BORDER), 0)
Global $TreeView = GUICtrlCreateTreeView(575, 35, 104, 101, $WS_BORDER)
Global $Group1 = GUICtrlCreateTreeViewItem("Group1", $TreeView)
Global $Group2 = GUICtrlCreateTreeViewItem("Group2", $TreeView)
Global $Group3 = GUICtrlCreateTreeViewItem("Group3", $TreeView)
Global $Group4 = GUICtrlCreateTreeViewItem("Group4", $TreeView)
Global $Group5 = GUICtrlCreateTreeViewItem("Group5", $TreeView)
_TabMenu()
GUISetState(@SW_SHOW)

While 1
	Local $nMsg = GUIGetMsg()
	If $nMsg = $GUI_EVENT_CLOSE Then Exit
	For $w = 0 To $numsM - 1
		If $nMsg = $Button[$w] Then
			GUICtrlSetData($Box, "-= Wait =-")
			$toPost = _Method($arrM[$w][1], $arrM[$w][3], GUICtrlRead($Input[$w][0], 1), $arrM[$w][5], GUICtrlRead($Input[$w][1], 1), $arrM[$w][7], GUICtrlRead($Input[$w][2], 1))
			$TextInBox = _PostReq($URL, $PORT, $toPost)
			Sleep(50)
			If $TextInBox Then
				$TextInBox = "-= SEND =- " & @CRLF & $toPost & @CRLF & "-= RETURN =-" & @CRLF & $TextInBox
			Else
				$TextInBox = "Error"
			EndIf
			GUICtrlSetData($Box, $TextInBox)
		EndIf
	Next
WEnd
Func _TabMenu($group="")
	Global $TabSheet[$numsM], $Button[$numsM], $Label[$numsM][4], $Input[$numsM][3]
	Global $Tab = GUICtrlCreateTab(5, 5, 691, 141, BitOR($TCS_FLATBUTTONS, $TCS_BUTTONS), 0)
	For $t = 0 To $numsM - 1
		$TabSheet[$t] = GUICtrlCreateTabItem($arrM[$t][1])
		$Button[$t] = GUICtrlCreateButton($arrM[$t][1], 14, 38, 176, 21)
		If $arrM[$t][2] Then
			$Label[$t][0] = GUICtrlCreateLabel($arrM[$t][3] & ": ", 14, 63, 176, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE));,$WS_BORDER))
			$Input[$t][0] = GUICtrlCreateInput("", 194, 63, 376, 21, BitOR($GUI_SS_DEFAULT_INPUT, $WS_BORDER), 0)
		EndIf
		If $arrM[$t][4] Then
			$Label[$t][1] = GUICtrlCreateLabel($arrM[$t][5] & ": ", 14, 88, 176, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE));,$WS_BORDER))
			$Input[$t][1] = GUICtrlCreateInput("", 194, 88, 376, 21, BitOR($GUI_SS_DEFAULT_INPUT, $WS_BORDER), 0)
		EndIf
		If $arrM[$t][6] Then
			$Label[$t][2] = GUICtrlCreateLabel($arrM[$t][7] & ": ", 14, 113, 176, 21, BitOR($SS_RIGHT, $SS_CENTERIMAGE));,$WS_BORDER))
			$Input[$t][2] = GUICtrlCreateInput("", 194, 113, 376, 21, BitOR($GUI_SS_DEFAULT_INPUT, $WS_BORDER), 0)
		EndIf
		$Label[$t][3] = GUICtrlCreateLabel($arrM[$t][0], 194, 38, 376, 21, BitOR(0, $SS_CENTERIMAGE));,$WS_BORDER))
	Next
	GUICtrlCreateTabItem("")
EndFunc   ;==>_TabMenu
Func _Method($name, $s1 = Default, $s2 = Default, $s3 = Default, $s4 = Default, $s5 = Default, $s6 = Default)
	Local $id = @MIN & @SEC & @MSEC, $arg[2], $params = $_JSONNull, $pstring = $_JSONNull
	If $s1 And $s2 Then
		$arg[0] = $s1
		$arg[1] = $s2
		$params = 'params'
	EndIf
	If $s3 And $s4 Then
		ReDim $arg[4]
		$arg[2] = $s3
		$arg[3] = $s4
	EndIf
	If $s5 And $s6 Then
		ReDim $arg[6]
		$arg[4] = $s5
		$arg[5] = $s6
	EndIf
	$pstring = _JSONObjectFromArray($arg)
	Return _JSONEncode(_JSONObject('method', $name, 'jsonrpc', '2.0', 'id', $id, $params, $pstring))
EndFunc   ;==>_Method
Func _PostReq($u = "localhost", $p = "default", $m = "")
	Local $hOpen = _WinHttpOpen()
	If @error Then
		MsgBox(48, "Error", "Error initializing the usage of WinHTTP functions.")
		Return @error
	EndIf
	Local $hConnect = _WinHttpConnect($hOpen, $u, $p)
	If @error Then
		MsgBox(48, "Error", "Error specifying the initial target server of an HTTP request.")
		_WinHttpCloseHandle($hOpen)
		Return @error
	EndIf
	Local $hRequest = _WinHttpOpenRequest($hConnect, "POST")
	If @error Then
		MsgBox(48, "Error", "Error creating an HTTP request handle.")
		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
		Return @error
	EndIf
	_WinHttpSendRequest($hRequest, Default, $m)
	If @error Then
		MsgBox(48, "Error", "Error sending specified request.")
		_WinHttpCloseHandle($hRequest)
		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
		Return @error
	EndIf
	_WinHttpReceiveResponse($hRequest)
	If @error Then
		MsgBox(48, "Error", "Error waiting for the response from the server.")
		_WinHttpCloseHandle($hRequest)
		_WinHttpCloseHandle($hConnect)
		_WinHttpCloseHandle($hOpen)
		Return @error
	EndIf
	Local $sChunk, $sData
	If _WinHttpQueryDataAvailable($hRequest) Then
		While 1
			$sChunk = _WinHttpReadData($hRequest);, 1)
			If @error Then ExitLoop
			$sData &= $sChunk
		WEnd
	Else
		MsgBox(48, "Error", "Site is experiencing problems.")
		Return @error
	EndIf
	_WinHttpCloseHandle($hRequest)
	_WinHttpCloseHandle($hConnect)
	_WinHttpCloseHandle($hOpen)
	Return $sData
EndFunc   ;==>_PostReq