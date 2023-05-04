CREATE PROCEDURE [Corp].[st_DismissComplianceNotificationByIdTransfer](

	 @IdTransfer Int, 

	 @IsSpanishLanguage bit, 

	 @HasError bit out, 

	 @MessageOut varchar(max) out 

)as
/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega "with(nolock)" a las consultas</log>
</ChangeLog>
*********************************************************************/

Begin Try

declare @IdMessages table (IdMessage int)

declare @totalMessages int

declare @totalErrors int



set @totalErrors = 0

set @totalMessages = 0



If exists(Select 1 From Transfer WITH(NOLOCK) where IdTransfer=@IdTransfer)

Begin



	insert into @IdMessages

	select TNN.IdMessage from TransferNoteNotification TNN WITH(NOLOCK)

	inner join TransferNote TN WITH(NOLOCK) on TNN.IdTransferNote = TN.IdTransferNote

	inner join TransferDetail TD WITH(NOLOCK) on TN.IdTransferDetail = TD.IdTransferDetail and TD.IdTransfer = @IdTransfer

	where TNN.IdGenericStatus = 1



End Else Begin

	

	insert into @IdMessages

	select TCNN.IdMessage from TransferClosedNoteNotification TCNN WITH(NOLOCK)

	inner join TransferClosedNote TCN WITH(NOLOCK) on TCNN.IdTransferClosedNote = TCN.IdTransferClosedNote

	inner join TransferClosedDetail TCD WITH(NOLOCK) on TCN.IdTransferClosedDetail = TCD.IdTransferClosedDetail and TCD.IdTransferClosed = @IdTransfer

	where TCNN.IdGenericStatus = 1



End



declare @CurrentIdMessage int

declare @CurrentHasError bit

declare @CurrertErrorMessage varchar(max)

while exists (select top 1 1 from @IdMessages)

begin 

	select top 1 @CurrentIdMessage= IdMessage from @IdMessages

	exec [Corp].[st_DismissComplianceNotification] @CurrentIdMessage, @IsSpanishLanguage, @CurrentHasError out, @CurrertErrorMessage out

	set @totalErrors = @totalErrors+@CurrentHasError

	set @totalMessages = @totalMessages+1

	delete @IdMessages where IdMessage = @CurrentIdMessage

end 



set @HasError = CASE WHEN @totalErrors > 0 THEN 1 ELSE 0 END

select @MessageOut=cast(@totalErrors AS VARCHAR(10))+' / '+cast(@totalMessages AS VARCHAR(10))+' '+ dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,66) 

End try
begin catch   
Declare @ErrorMessage nvarchar(max)                                                                                             
Select @ErrorMessage=ERROR_MESSAGE()                                                      
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DismissComplianceNotificationByIdTransfer]',Getdate(),@ErrorMessage)                                                                                            
end catch

