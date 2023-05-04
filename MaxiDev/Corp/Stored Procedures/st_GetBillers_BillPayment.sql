CREATE PROCEDURE [Corp].[st_GetBillers_BillPayment]
   @IdAggregator int = null,
   @Status int = null,
   @DateFrom date = null,
   @DateTo date = null,
   @Like varchar(max) = null
AS

/********************************************************************
<Author>djuarez</Author>
<app>MaxiCorp</app>
<Description>Obtener Biller por Aggregator, filtrado por fecha</Description>
*********************************************************************/

DECLARE @countStatesCountry int

SELECT
	@countStatesCountry = COUNT(1)
FROM State WITH(NOLOCK)
WHERE IdCountry = 18

IF (@IdAggregator = 0)
SET @IdAggregator = NULL

IF (@Status = 3)
SET @Status = NULL

IF @DateTo IS NOT NULL AND @DateTo <> ''
SET @DateTo = DATEADD(DAY, 1, @DateTo)
ELSE
SET @DateTo = DATEADD(DAY, 1, GETDATE())

IF OBJECT_ID('tempdb.dbo.#TmpBills', 'U') IS NOT NULL
  DROP TABLE #TmpBills; 

;WITH cte_Bills
AS
(SELECT
		B.IdBiller
	   ,B.Name
	   ,B.NameAggregator
	   ,Aggregator = A.Name
	   ,B.IdAggregator
	   ,B.Posting
	   ,B.PostingAggregator
	   ,B.BuyRate
	   ,Relationship =
		CASE
			WHEN
				B.Relationship = '' AND
				B.Posting = 'Same Day Post' THEN 'Autorized'
			WHEN
				B.Relationship = '' THEN 'Non Contracted'
			ELSE B.Relationship
		END
	   ,Presence =
		(
		CASE
			WHEN B.IsDomestic = 1 THEN CASE
					WHEN (@countStatesCountry = (SELECT
								COUNT(1)
							FROM BillPayment.StateForBillers S WITH(NOLOCK)
							WHERE S.IdBiller = B.IdBiller
							AND S.IdStatus = 1)
						) THEN 'National'
					ELSE 'Define'
				END
			WHEN
				B.IsDomestic = 0 THEN 'International'
		END
		)
	   ,B.CutOffTime
	   ,StatusBiller =
		(CASE
			WHEN B.IdStatus = 0 THEN 'New'
			WHEN B.IdStatus = 1 THEN 'Enabled'
			WHEN B.IdStatus = 2 THEN 'Disabled'
		END
		)
	   ,B.IdStatus
	   ,B.IdBillerOfClone
	   ,NameBillerOfClone = ISNULL((SELECT
				B2.Name
			FROM BillPayment.Billers B2 WITH (NOLOCK)
			WHERE B2.IdBiller = B.IdBillerOfClone)
		, '')
	   ,DateOfCreation = ISNULL((SELECT
				MIN(L.DateLastChangue)
			FROM BillPayment.LogForBillers L WITH (NOLOCK)
			WHERE L.IdBiller = B.IdBiller
			AND L.Description = 'Status change 1')
		, GETDATE())
	   ,DateOfCreationString = ISNULL((SELECT
				CAST(MIN(L.DateLastChangue) AS NVARCHAR)
			FROM BillPayment.LogForBillers L WITH (NOLOCK)
			WHERE L.IdBiller = B.IdBiller
			AND L.Description = 'Status change 1')
		, '')
	   ,B.IdBillerAggregator
	   ,B.Category
	   ,B.CategoryAggregator
	   ,DateOfEdit = ISNULL((SELECT
				CAST(MAX(L.DateLastChangue) AS NVARCHAR)
			FROM BillPayment.LogForBillers L WITH (NOLOCK)
			WHERE L.IdBiller = B.IdBiller
			AND L.MovementType = 'Update Info')
		, '')
	   ,DateOfStatusUpdate = ISNULL((SELECT
				CAST(MAX(L.DateLastChangue) AS NVARCHAR)
			FROM BillPayment.LogForBillers L WITH (NOLOCK)
			WHERE L.IdBiller = B.IdBillerAggregator
			AND L.MovementType = 'Update Status')
		, '')
	   ,ISNULL(ChoiseData, '') AS ChoiseData
	   ,IsFixedFee
	   ,@DateFrom AS 'Date From'
	FROM BillPayment.Billers B WITH (NOLOCK)
	INNER JOIN BillPayment.Aggregator A WITH (NOLOCK)
		ON A.IdAggregator = B.IdAggregator
	WHERE B.IdAggregator = ISNULL(@IdAggregator, B.IdAggregator)
	AND B.IdStatus = ISNULL(@Status, B.IdStatus))

SELECT
	* INTO #TmpBills
FROM cte_Bills

IF @Like IS NULL
	OR @Like = ''
BEGIN

SELECT
	*
FROM #TmpBills
WHERE #TmpBills.DateOfCreation >= ISNULL(@DateFrom, #TmpBills.DateOfCreation)
AND #TmpBills.DateOfCreation <= ISNULL(@DateTo, #TmpBills.DateOfCreation)
--ORDER by bills.IdBillerAggregator

END
ELSE
BEGIN

SELECT
	*
FROM #TmpBills
WHERE #TmpBills.DateOfCreation >= ISNULL(@DateFrom, #TmpBills.DateOfCreation)
AND #TmpBills.DateOfCreation <= ISNULL(@DateTo, #TmpBills.DateOfCreation)
AND (#TmpBills.Name LIKE '%' + @Like + '%'
OR #TmpBills.IdBillerAggregator LIKE '%' + @Like + '%')
--ORDER by bills.IdBillerAggregator

END
