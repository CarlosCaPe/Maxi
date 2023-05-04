CREATE PROCEDURE [Corp].[st_RejectCheckNotificationFromBulkCheck]
(
    @IdCheck int,
    @EnterByIdUser int,
    @Note nvarchar(MAX)        
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2020/01/15" Author="jrivera">s24_17 :: Add Notification of check rejected from bulk check reject.. </log>
</ChangeLog>
********************************************************************/
	DECLARE @rawMessage VARCHAR(MAX)
	DECLARE @IdMessage INT
	DECLARE @IdAgent INT

	BEGIN TRY

	SELECT TOP 1
	
	@rawMessage =
		'{
		"idCheck":' + CONVERT(VARCHAR(MAX),c.IdCheck) + ',
		"IsRejectCheck":true,
		"AgentCode":"' + a.AgentCode + '",
		"AgentName":"' + a.AgentName + '",
		"Folio":"'+ CONVERT(VARCHAR(MAX),c.IdCheck)+'",
		"CheckNumber":"' + c.CheckNumber+ '",
		"ClaimCode":"' + c.ClaimCheck + '",
		"CustomerName":"' + c.Name + ' '+ c.FirstLastName + ' ' + c.SecondLastName + '",
		"DateOfTransfer":"' + CONVERT(VARCHAR(MAX),c.DateOfMovement) + '",
		"Note":"' + @Note + '",
		"Requirement":[]}',
		@IdAgent = c.idAgent
	FROM Checks c WITH(NOLOCK)
	JOIN agent a WITH(NOLOCK) ON a.IdAgent = c.IdAgent
	JOIN CheckDetails d WITH(NOLOCK) ON c.IdStatus = d.IdStatus
	WHERE c.IdCheck = @IdCheck AND c.IdStatus = 31 --AND d.Note = 'Returned Check (NSF-Insuf Funds)'


	IF EXISTS (SELECT TOP 1 1 from CheckDetails CD WITH(NOLOCK) inner join Checks c WITH(NOLOCK) on CD.IdStatus = c.IdStatus where c.IdCheck = @IdCheck AND c.IdStatus = 31)
	BEGIN
		INSERT INTO msg.Messages (IdMessageProvider, IdUserSender,RawMessage, DateOfLastChange )
		VALUES (2,@EnterByIdUser, @rawMessage, GETDATE() )

		SET @IdMessage = @@IDENTITY;

		INSERT INTO msg.MessageSubcribers (IdMessage, IdUser, IdMessageStatus, DateOfLastChange, MessageIsRead)
		SELECT @IdMessage, idUser, 1, GETDATE(),0
		FROM AgentUser au with(nolock)		
		WHERE au.idAgent = @idAgent
	END

	PRINT CONVERT(VARCHAR(MAX), @IdMessage)
END TRY
BEGIN CATCH    
	DECLARE @ErrorMessage nvarchar(max) = ERROR_MESSAGE()                                             
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_RejectCheckNotificationFromBulkCheck] : ' ,Getdate(), ISNULL(@rawMessage,'') +  @ErrorMessage)                                                                                            
END CATCH




