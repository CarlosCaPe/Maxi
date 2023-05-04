
CREATE procedure [dbo].[InsCheckRejectHistory]
(
	@IdCheck int
	,@EnterByIdUser int
	,@Note nvarchar(max)
)
AS

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2020/06/28" Author="djuarez;mpadilla">Se agrega validación @IdReturnedReason Nulo</log>
</ChangeLog>
********************************************************************/

SET NOCOUNT ON;
BEGIN TRY
	declare @RoutingNumber varchar(max) , @AccountNumber varchar(max),@IdReturnedReason int
	--DEV,QA: ReturnedReason_ID, STAGE: ReturnReason_ID
	Select @IdReturnedReason = ReturnReason_ID from CheckConfig.ReasonBanksRejetedChecks with(nolock) where rtrim(ltrim(@Note)) LIKE '%' + rtrim(ltrim(MaxiReason)) + '%'
	Select @RoutingNumber = RoutingNumber, @AccountNumber = Account from Checks with(nolock) where IdCheck = @IdCheck

	IF @IdReturnedReason is null
	BEGIN
		Select @IdReturnedReason = ReturnedReason_ID from dbo.ActionNotes with(nolock) where rtrim(ltrim(@Note)) LIKE '%' + rtrim(ltrim(Note)) + '%'
	END

	INSERT INTO [dbo].[CheckRejectHistory]
			(IdCheck
			,RoutingNumber
			,AccountNumber
			,IdReturnedReason
			,DateOfReject
			,EnterByIdUser
			,CreationDate
			,DateofLastChange)
		VALUES
			(@IdCheck
			,@RoutingNumber
			,@AccountNumber
			,@IdReturnedReason
			,GETDATE()
			,@EnterByIdUser
			,GETDATE()
			,GETDATE())

END TRY
BEGIN CATCH        
	declare @Message varchar(max) 
	SELECT @Message = dbo.GetMessageFromMultiLenguajeResorces(1,'CHRER')       
	DECLARE @ErrorMessage nvarchar(max) =ERROR_MESSAGE()                                   
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('InsCheckRejectHistory',Getdate(),@ErrorMessage)                                                                                            
END CATCH