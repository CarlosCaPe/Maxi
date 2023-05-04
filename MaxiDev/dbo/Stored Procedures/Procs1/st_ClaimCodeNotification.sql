CREATE PROCEDURE [dbo].[st_ClaimCodeNotification] (@Folio int, @IdPayer int, @SendMessage bit out)
AS
BEGIN

	DECLARE @MinimunFolio int, @NextFolioToNotification int, @RangeFolio int

	SELECT @MinimunFolio = MinimunFolio,
		   @RangeFolio = RangeFolio,
	       @NextFolioToNotification = NextFolioToNotification
	  FROM dbo.ClaimCodeNotificationRules AS ccnr WITH(NOLOCK) 
	 WHERE 1 = 1 
	   AND IdPayer = @IdPayer

	IF (@Folio >= @MinimunFolio AND @Folio >= @NextFolioToNotification)
	BEGIN
		UPDATE dbo.ClaimCodeNotificationRules 
		   SET NextFolioToNotification = (@Folio + @RangeFolio) 
		 WHERE IdPayer = @IdPayer

		SET @SendMessage = 1
	END
	ELSE
	BEGIN
		SET @SendMessage = 0
	END
END