CREATE PROCEDURE [MoneyAlert].[st_HistoryChat]
(
@IdChat varchar(max),
@PageChat int,
@IdPersonRole int,
@HasError bit out
)
AS
SET NOCOUNT ON
BEGIN TRY
	SET @HasError=0

	Set @PageChat=@PageChat*20

	IF @IdPersonRole=1
		UPDATE MoneyAlert.ChatDetail SET ChatMessageStatusId=2 WHERE IdChat=@IdChat AND ChatMessageStatusId=1 AND IdPersonRole=2

	IF @IdPersonRole=2
		UPDATE MoneyAlert.ChatDetail SET ChatMessageStatusId=2 WHERE IdChat=@IdChat AND ChatMessageStatusId=1 AND IdPersonRole=1


SELECT  IdPersonRole,ChatMessage,EnteredDate INTO #TEMP
FROM    ( SELECT    ROW_NUMBER() OVER ( ORDER BY EnteredDate desc) AS RowNum, *
          FROM      MoneyAlert.ChatDetail
		  WHERE IdChat=@IdChat
        ) AS RowConstrainedResult
WHERE   RowNum >= 1
    AND RowNum <= @PageChat
ORDER BY EnteredDate 


INSERT INTO #TEMP (IdPersonRole,ChatMessage,EnteredDate)
SELECT 3, CONVERT(VARCHAR(11),EnteredDate,106) ,CONVERT(VARCHAR(11),EnteredDate,106)   FROM #TEMP
GROUP BY CONVERT(VARCHAR(11),EnteredDate,106) 

SELECT IdPersonRole,ChatMessage, RIGHT(CONVERT(VARCHAR(30), EnteredDate, 0), 8) as ChatTime,@IdChat as IdChat FROM #TEMP ORDER BY EnteredDate
      
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH










