CREATE PROC Corp.st_GetOfacValidationReportExcel
	@IdOfacValidation	INT
AS
BEGIN
	
	IF OBJECT_ID('tempdb..#MatchListTmp') IS NOT NULL
	DROP TABLE #MatchListTmp
	
	IF OBJECT_ID('tempdb..#AkaListTmp') IS NOT NULL
	DROP TABLE #AkaListTmp
	
	IF OBJECT_ID('tempdb..#AkaStringTmp') IS NOT NULL
	DROP TABLE #AkaStringTmp
	
	IF OBJECT_ID('tempdb..#MatchAkaListTmp') IS NOT NULL
	DROP TABLE #MatchAkaListTmp
	
	IF OBJECT_ID('tempdb..#FinalMatchAkaStringTmp') IS NOT NULL
	DROP TABLE #FinalMatchAkaStringTmp
	
	

	SELECT ROW_NUMBER() OVER (PARTITION BY OD.IdOfacValidationDetail ORDER BY OD.IdOfacValidationDetail) AS RowNum, 
		OD.IdOfacValidationDetail, 
		ODM.IdOfacValidationDetailMatch,
		ODM.NameComplete + ' ( ' + ODM.Remarks + ' Score: ' + convert(VARCHAR(10), ODM.Score) + ' )' AS MatchName
	INTO #MatchListTmp
	FROM Corp.OfacValidationDetail OD INNER JOIN
		Corp.OfacValidationDetailMatch ODM ON ODM.IdOfacValidationDetail = OD.IdOfacValidationDetail
	WHERE OD.IdOfacValidation = @IdOfacValidation
	
	
	SELECT OD.IdOfacValidationDetail,
		ODM.IdOfacValidationDetailMatch,
		ODMA.NameComplete AS AkaName
	INTO #AkaListTmp
	FROM Corp.OfacValidationDetail OD INNER JOIN
		Corp.OfacValidationDetailMatch ODM ON ODM.IdOfacValidationDetail = OD.IdOfacValidationDetail INNER JOIN
		Corp.OfacValidationDetailMatchAka ODMA ON ODMA.IdOfacValidationDetailMatch = ODM.IdOfacValidationDetailMatch
	WHERE OD.IdOfacValidation = @IdOfacValidation
	
	
	SELECT  IdOfacValidationDetail
			,IdOfacValidationDetailMatch
	       ,STUFF((SELECT ', ' + CAST(AkaName AS VARCHAR(max)) [text()]
	         FROM #AkaListTmp 
	         WHERE IdOfacValidationDetail = t.IdOfacValidationDetail
	         	AND IdOfacValidationDetailMatch = t.IdOfacValidationDetailMatch
	         FOR XML PATH(''), TYPE)
	        .value('.','NVARCHAR(MAX)'),1,2,' ') ListAka
	INTO #AkaStringTmp     
	FROM #AkaListTmp t
	GROUP BY IdOfacValidationDetail, IdOfacValidationDetailMatch
	
	SELECT A.IdOfacValidationDetail, A.IdOfacValidationDetailMatch,
		'Match' + convert(VARCHAR(10), A.RowNum) + ' ' + A.MatchName + ', AKA: ' + B.ListAka AS MatchAkaName
	INTO #MatchAkaListTmp
	FROM #MatchListTmp A LEFT JOIN
		#AkaStringTmp B ON A.IdOfacValidationDetail = B.IdOfacValidationDetail
						AND A.IdOfacValidationDetailMatch = B.IdOfacValidationDetailMatch
						
	SELECT  IdOfacValidationDetail		
	       ,STUFF((SELECT ' | ' + CAST(MatchAkaName AS VARCHAR(max)) [text()]
	         FROM #MatchAkaListTmp 
	         WHERE IdOfacValidationDetail = t.IdOfacValidationDetail
	         FOR XML PATH(''), TYPE)
	        .value('.','NVARCHAR(MAX)'),1,2,' ') ListMatchAka
	INTO #FinalMatchAkaStringTmp     
	FROM #MatchAkaListTmp t
	GROUP BY IdOfacValidationDetail	  
	
	
	SELECT O.IdOfacValidation, OD.IdOfacValidationDetail, OD.Name, OD.DateOfBirth, OD.CountryOfBirth, S.Name AS 'Status', E.Name AS 'Type',
		OD.StatusChangeNote, isnull(U.UserName, '') AS 'UserStatusChange', OD.DateOfApproval AS 'DateStatusChange' ,	 	
		isnull(M.ListMatchAka, '') AS 'MatchDescription' --ODM.Score, ODM.NameComplete AS 'MatchName', ODM.Remarks	 
	FROM Corp.OfacValidation O INNER JOIN	
		Corp.OfacValidationDetail OD ON OD.IdOfacValidation = o.IdOfacValidation INNER JOIN
		Corp.OfacValidationEntityType E ON E.IdOfacValidationEntityType = OD.IdOfacValidationEntityType LEFT JOIN
		Users U ON U.IdUser = OD.IdUserApprove LEFT  JOIN
		Corp.OfacValidationStatus S ON S.Code = OD.GeneralStatus LEFT JOIN
		#FinalMatchAkaStringTmp M ON M.IdOfacValidationDetail = OD.IdOfacValidationDetail
	WHERE O.IdOfacValidation = @IdOfacValidation

END

