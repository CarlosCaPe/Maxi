CREATE procedure [dbo].[st_CheckReject]
 (
    @EnterByIdUser INT,
    @IsSpanishLanguage BIT,
    @Checks XML,
    @HasError BIT OUT,
    @Message NVARCHAR(MAX) OUT
 )
 AS
 /********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/06/05" Author="mdelgado">s24_17 :: Add Notification of check rejected if agent allow notifications.. </log>
</ChangeLog>
********************************************************************/
 SET NOCOUNT ON
 BEGIN TRY

	DECLARE @DocHandle INT 

	EXEC sp_xml_preparedocument @DocHandle OUTPUT,@Checks 


	CREATE Table #Checks( 
	IdCheck INT,
	)

	

  INSERT INTO #Checks
	SELECT  IdCheck			
			From OPENXML (@DocHandle, '/Checks/Check',2)
			WITH(
			IdCheck INT
		)

  DECLARE @Note nvarchar(max)
 
  SET @Note = 'Cheque rechazado por falta de imágenes'

  Update CheckHolds set IsReleased=0, DateOfLastChange=GetDate(),EnterByIdUser=@EnterByIdUser where IdCheck in (Select IdCheck From #Checks) and  IsReleased is null

  Update Checks Set IdStatus = 31,DateStatusChange = GETDATE() Where IdCheck in (Select IdCheck From #Checks)
  
	Declare @DateNow Datetime
	Set @DateNow = GETDATE() + .001

	DECLARE @IdCheck INT

	WHILE EXISTS (Select TOP 1 1 From #Checks)
	BEGIN

		SELECT TOP 1 @IdCheck = IdCheck FROM #Checks

		--EXEC [dbo].[st_RejectCheckNotification] @IdCheck, @EnterByIdUser, @Note
		
		Insert into [CheckDetails] (IdStatus,IdCheck,DateOfMovement,note,EnterByIdUser) values (31,@IdCheck,@DateNow,@Note,@EnterByIdUser)  

		DELETE FROM #Checks WHERE IdCheck = @IdCheck
  
	END

   Select @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,30)
   Set @HasError = 0

End Try
Begin Catch
	Set @HasError=1
	Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	Declare @ErrorMessage nvarchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CheckReject',Getdate(),@ErrorMessage)
End Catch