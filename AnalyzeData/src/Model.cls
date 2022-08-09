VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Model"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'********************************************************************************************
'* Description  :�����Ƃ�PCR�����z���Ґ��̗݌v��Ԃ�
'********************************************************************************************
Public Function CalcPosTotal(filePath As String) As Long

    Dim objUtil As Util
    Dim posCnts() As Variant
    Dim posTotal As Long
    Dim lngPosCnt As Long, i As Long
    
    Set objUtil = New Util
    
    '�����Ƃ̗z���Ґ���z��Ŏ擾
    posCnts = objUtil.LoadDataFromCSV(filePath)
    
    '�����Ƃ̗z���Ґ��̗݌v���v�Z
    On Err GoTo ErrHandler
    posTotal = 0
    lngPosCnt = 0
    For i = 0 To UBound(posCnts)
        '1���ږڂ����t�ł���2���ږڂ����l�ł����Long�^�ɕϊ����ė݌v�Ɍv��
        If IsDate(posCnts(i, 0)) <> False And IsNumeric(posCnts(i, 1)) Then
            lngPosCnt = CLng(posCnts(i, 1))
            posTotal = posTotal + lngPosCnt
        Else
            Debug.Print (i + 1) & "�s�ڂ̃f�[�^:" & posCnts(i, 0) & "," & posCnts(i, 1)
            Err.Raise Number:=500, Description:=(i + 1) & "�s�ڂ̃f�[�^���s���ł�"
        End If
    Next i
    
    CalcPosTotal = posTotal
    Exit Function
    
ErrHandler:
    Err.Raise Err.Number, Err.Source, Err.Description
    
End Function
