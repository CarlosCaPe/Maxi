CREATE procedure [Corp].[st_RejectCheckByIdUser]
(
--declare
    @IdCheck int ,--= 15076,
    @EnterByIdUser int  ,--=1,
    @Note nvarchar(max) ,--= 'Returned Check (Closed Account)',
    @IdLenguage int ,--= 1,
    @HasError BIT out,--= 1,
    @Message varchar(max) out--=''
)
AS
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/06/05" Author="mdelgado">s24_17 :: Add Notification of check rejected if agent allow notifications.. </log>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON;
BEGIN TRY

	IF EXISTS (SELECT 1 FROM Checks with(nolock) WHERE IdCheck=@IdCheck and IdStatus=30)
	BEGIN

	UPDATE [dbo].[Checks] Set IdStatus = 31,DateOfLastChange = GETDATE(), DateStatusChange = GETDATE() WHERE IdCheck = @IdCheck;

	INSERT INTO [dbo].[CheckDetails] ([IdCheck], [IdStatus], [DateOfMovement], [Note], [EnterByIdUser])
		VALUES ( @IdCheck, 31, getdate(), @Note, @EnterByIdUser );
    
	EXEC [Corp].[st_CheckCancelToAgentBalance_Checks] @IdCheck,@EnterByIdUser,1;

	DECLARE @tmpDate DATETIME
	SET @tmpDate = GETDATE()
	
	EXEC [Corp].[InsCheckRejectHistory] @IdCheck,@EnterByIdUser, @Note, @tmpDate

	IF @Note LIKE '%Closed Account%'
	Begin
		DECLARE @ReturnDate datetime = getdate()
		EXECUTE [Corp].[st_InsertDenyListIssuerChecks_Checks] @EnterByIdUser, @IdCheck, @ReturnDate, '', 0
	End



	--- REGISTRO DE ALERTA DE RECHAZO MANUAL DE CHEQUE
	--EXEC [dbo].[st_RejectCheckNotification] @IdCheck, @EnterByIdUser, @Note

		SET @HasError=0                                                                                   
		SELECT @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CHROK')       

	RETURN
	END

	SET @HasError=1                                                                                   
	SELECT @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CHRER')  

END TRY
BEGIN CATCH
    SET @HasError=1                                                                                   
    SELECT @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'CHRER')       
	DECLARE @ErrorMessage nvarchar(max) =ERROR_MESSAGE()                                             
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_RejectCheckByIdUser]',Getdate(),@ErrorMessage)                                                                                            
END CATCH


