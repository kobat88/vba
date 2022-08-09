Attribute VB_Name = "DeleteData1"
'Option Explicit

'Excel上でソート -> 配列内で検索してフラグを立てる -> Excelに戻してフラグでフィルタして削除
'シート１：1000件 シート２：8000件で3.5秒

Public Sub DeleteData1()

    Const WS_NAME1 = "Sheet1"
    Const WS_NAME2 = "Sheet2"
    Const WS_NAME1_SORT = "Sheet1_sort"
    Const WS_NAME2_SORT = "Sheet2_sort"

    Dim objUtil As Util
    Dim lastRow1 As Long, lastRow2 As Long
    Dim Arry1() As Variant, Arry2() As Variant
    Dim minRowIdx As Long, maxRowIdx As Long
    Dim i As Long, j As Long, csrJ As Long, k As Long
    Dim startTime As Single, endTime As Single, procTime As Single
    Dim startTime1 As Single, endTime1 As Single
    Dim startTime2 As Single, endTime2 As Single
    Dim startTime3 As Single, endTime3 As Single
    Dim startTime4 As Single, endTime4 As Single

    startTime = Timer
    
    Debug.Print "処理開始"
    
    Application.ScreenUpdating = False
    Application.DisplayAlerts = False

    Set objUtil = New Util
    
    'シート１，シート２の最終行を取得
    lastRow1 = Worksheets(WS_NAME1).Cells(Rows.Count, 1).End(xlUp).Row
    lastRow2 = Worksheets(WS_NAME2).Cells(Rows.Count, 1).End(xlUp).Row
    
    
    startTime1 = Timer
    'シート１データをソート用シート１にコピーしてソート
    Worksheets(WS_NAME1).Copy After:=Worksheets(WS_NAME1)
    ActiveSheet.Name = WS_NAME1_SORT
    
    With Worksheets(WS_NAME1_SORT)
        '元の並び順を9列目に記録
        For k = 2 To lastRow1
            .Cells(k, 9).Value = k
        Next
        '1列目でソート
        .Range("A1").CurrentRegion.Sort Key1:=.Range("A1"), Header:=xlYes
    End With
    
    'シート２データをソート用シート２にコピーしてソート
    Worksheets(WS_NAME2).Copy After:=Worksheets(WS_NAME2)
    ActiveSheet.Name = WS_NAME2_SORT
    
    With Worksheets(WS_NAME2_SORT)
        '元の並び順を9列目に記録
        For k = 2 To lastRow2
            .Cells(k, 9).Value = k
        Next
        '1列目でソート
        .Range("A1").CurrentRegion.Sort Key1:=.Range("A1"), Header:=xlYes
    End With
    endTime1 = Timer
    Debug.Print "ソート処理:" & endTime1 - startTime1
    

    '各ソート用シートのデータを配列に格納
    startTime2 = Tiemr
    Arry1 = objUtil.LoadDataFromSheet(ThisWorkbook, WS_NAME1_SORT, 2, 1, 8)
    Arry2 = objUtil.LoadDataFromSheet(ThisWorkbook, WS_NAME2_SORT, 2, 1, 10)
    endTime2 = Timer
    Debug.Print "配列へ格納処理:" & endTime2 - startTime2


    'いずれかの配列が空であれば処理終了
    If objUtil.IsEmptyArry(Arry1) Or objUtil.IsEmptyArry(Arry2) Then
        Debug.Print "比較対象データが空です"
        Exit Sub
    End If

    minRowIdx = LBound(Arry2, 1)
    maxRowIdx = UBound(Arry2, 1)

    'メイン処理
    startTime3 = Timer
    csrJ = LBound(Arry1, 1)
    '配列２の先頭行から順に処理
    For i = LBound(Arry2, 1) To UBound(Arry2, 1)
        '10列目に"not exist"を格納
        Arry2(i, 9) = "not exist"
        '配列１の先頭行から順にチェック
        For j = csrJ To UBound(Arry1, 1)
            '配列２のA列=配列１のA列であれば、配列２の10列目を"exist"に更新し、配列２の次の行へ
            If Arry2(i, 0) = CStr(Arry1(j, 0)) Then
                Arry2(i, 9) = "exist"
                csrJ = j
                Exit For
            End If
        Next j
    Next i
    endTime3 = Timer
    Debug.Print "メイン処理:" & endTime3 - startTime3

    'ソート用シート２の既存データ行を削除
    Worksheets(WS_NAME2_SORT).Rows("2:" & Cells.Rows.Count).Delete

    '配列２のデータをソート用シート２に出力
    startTime4 = Timer
    Call objUtil.OutDataToSheet(ThisWorkbook, WS_NAME2_SORT, 2, 1, Arry2)
    endTime4 = Timer
    Debug.Print "シートへの出力処理:" & endTime4 - startTime4
    
    'ソート用シート２を10列目="exist"でフィルター
    Worksheets(WS_NAME2_SORT).Range("A1").AutoFilter 10, "exist"
    
    'フィルターした行を削除
    With Worksheets(WS_NAME2_SORT).Range("A1").CurrentRegion
        .Resize(.Rows.Count - 1).Offset(1, 0).Delete
    End With
    
    'フィルター解除
    Worksheets(WS_NAME2_SORT).Range("A1").AutoFilter
    
    'ソート用シート２のデータを元の並び順でソート
    Worksheets(WS_NAME2_SORT).Range("A1").CurrentRegion.Sort Key1:=Worksheets(WS_NAME2_SORT).Range("I1"), Header:=xlYes

    'ソート用シート２の9､10列目をクリア
    Worksheets(WS_NAME2_SORT).Columns(9).Clear
    Worksheets(WS_NAME2_SORT).Columns(10).Clear

    'シート２を削除
    Worksheets(WS_NAME2).Delete

    'ソート用シート２をシート２へコピー
    Worksheets(WS_NAME2_SORT).Copy After:=Worksheets(WS_NAME1)
    ActiveSheet.Name = WS_NAME2

    'ソート用シートを削除
    Worksheets(WS_NAME1_SORT).Delete
    Worksheets(WS_NAME2_SORT).Delete
    
    Application.ScreenUpdating = True
    Application.DisplayAlerts = False

    Debug.Print "処理終了"
    
    endTime = Timer
    procTime = endTime - startTime
    
    Debug.Print "処理時間:" & procTime

End Sub

