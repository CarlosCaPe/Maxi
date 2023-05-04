


CREATE PROCEDURE [dbo].[st_RejectCheckNotification]
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
<log Date="2017/06/05" Author="mdelgado">s24_17 :: Add Notification of check rejected if agent allow notifications.. </log>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/
	DECLARE @rawMessage VARCHAR(MAX)
	DECLARE @IdMessage INT
	DECLARE @IdAgent INT

	BEGIN TRY

	SELECT 
	
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
	FROM [dbo].Checks AS c WITH(NOLOCK)
	JOIN [dbo].agent AS a WITH(NOLOCK) ON a.IdAgent = c.IdAgent
	WHERE c.IdCheck = @IdCheck


	IF EXISTS (SELECT 1 from [dbo].agent WITH(NOLOCK) WHERE idagentcommunication in (1, 4) AND idagent = @IdAgent)
	BEGIN
		INSERT INTO msg.[Messages] (IdMessageProvider, IdUserSender,RawMessage, DateOfLastChange )
		VALUES (2,@EnterByIdUser, @rawMessage, GETDATE() )

		SET @IdMessage = @@IDENTITY;

		INSERT INTO msg.MessageSubcribers (IdMessage, IdUser, IdMessageStatus, DateOfLastChange, MessageIsRead)
		SELECT @IdMessage, idUser, 1, GETDATE(),0
		FROM [dbo].AgentUser AS au with(nolock)		
		WHERE au.idAgent = @idAgent
	END

	PRINT CONVERT(VARCHAR(MAX), @IdMessage)
END TRY
BEGIN CATCH    
	DECLARE @ErrorMessage nvarchar(max) = ERROR_MESSAGE()                                             
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RejectCheckNotification : ' ,Getdate(), ISNULL(@rawMessage,'') +  @ErrorMessage)                                                                                            
END CATCH


