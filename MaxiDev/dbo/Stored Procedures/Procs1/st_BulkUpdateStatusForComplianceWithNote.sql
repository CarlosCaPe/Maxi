﻿
CREATE procedure [dbo].[st_BulkUpdateStatusForComplianceWithNote]
 (
 @EnterByIdUser int,
 @IsSpanishLanguage bit,
 @XMLTransfer xml,
 @StatusHold int,
 @NewIdStatus int, --This parameter will be ignored, TODO: remove and update DBML
 @HasError bit out,
 @MessageOut varchar(max) out
 )
as
/**
Store Log:
2012/11/7	Aldo Romo	Changes to support new MultiHold Logic
**/
Set nocount on
Begin try
	Set @MessageOut=''

	Declare @Temp Table
	(
	Id int identity(1,1),
	Transfer Int,
	Note nvarchar(max),
	Mensaje nvarchar(max),
	Response bit
	)

	Declare @DocHandle int
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XMLTransfer
	Insert into @Temp (Transfer,Note)
	SELECT Transfer,Note FROM OPENXML (@DocHandle, 'Main/ValidTransfer',2) WITH (Transfer int,Note nvarchar(max))
	EXEC sp_xml_removedocument @DocHandle


	Declare @NoteTemp nvarchar(max)
	Declare @Counter int
	Set @Counter=1
	Declare @HasErrorTemp bit, @MessageTemp varchar(max),@TransferTemp int,@Mt nvarchar(max)


	While exists (Select top 1 1 from @Temp where ID>=@Counter)
	Begin
		 Select @TransferTemp=Transfer,@NoteTemp=Note from @Temp where ID=@Counter

		 ---------------------------------------

		 EXEC st_UpdateVerifyHold
			 @EnterByIdUser,
			 @IsSpanishLanguage,
			 @TransferTemp,
			 @NoteTemp,
			 @StatusHold,
			 1, --Bulks only can be performed to Release (thats the reason to ingore @NewIdStatus parameter)
			 @HasError=@HasErrorTemp OUTPUT,
			 @Message=@MessageTemp OUTPUT

		 ---------------------------------------
		 Update @Temp Set Mensaje=@MessageTemp,Response=@HasErrorTemp where ID=@Counter
		 Set @Counter=@Counter+1
	End


	Select @Mt=Convert(nvarchar(10),COUNT(1)) +' '+ Mensaje from @Temp where Response=0 Group by Mensaje
	Select @MessageOut=Convert(nvarchar(10),COUNT(1)) +' '+ Mensaje from @Temp where Response=1 Group by Mensaje

	Set @HasError=0
	If @MessageOut<>''
		Set @MessageOut=isnull(@Mt,'')+' '+CHAR(13)+CHAR(10)+Isnull(@MessageOut,'')
	Else
		Set @MessageOut=isnull(@Mt,'')+''+CHAR(13)+CHAR(10)+Isnull(@MessageOut,'')
	
 End Try
Begin Catch
	 Set @HasError=1
	 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)
	 Declare @ErrorMessage nvarchar(max)
	 Select @ErrorMessage=ERROR_MESSAGE()
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_BulkUpdateStatusForComplianceWithNote',Getdate(),@ErrorMessage)
End Catch
