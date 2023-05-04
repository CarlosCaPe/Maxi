CREATE procedure [dbo].[st_TransferCheckedAsReviewRejected] 
@IdTransfer int,
@IsSpanishLanguage bit,

@HasError bit out,
@ResultMessage nvarchar(max) out
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @reviewRejected bit

Begin try

if exists (select 1 from [Transfer] with(nolock) where IdTransfer =@IdTransfer)
Begin
	if exists (select 1 from [Transfer] with(nolock) where IdTransfer =@IdTransfer and ReviewRejected=1)
		Begin
			set @HasError =1
			set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,43)
		End
	Else
		Begin
			set @HasError =0
			set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,41)
			update [Transfer] set ReviewRejected =1 where IdTransfer= @IdTransfer
		End
	return;
End

if exists (select 1 from TransferClosed with(nolock) where IdTransferClosed =@IdTransfer)
Begin
	if exists (select 1 from TransferClosed with(nolock) where IdTransferClosed =@IdTransfer and ReviewRejected=1)
		Begin
			set @HasError =1
			set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,43)
		End
	Else
		Begin
			set @HasError =0
			set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,41)
			update TransferClosed set ReviewRejected =1 where IdTransferClosed= @IdTransfer;
		End
	return;
End


End try
Begin Catch
		 Declare @ErrorMessage nvarchar(max)         
		 Select @ErrorMessage=ERROR_MESSAGE()        
		 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_TransferCheckedAsReviewRejected]',Getdate(),@ErrorMessage) ;
		set @HasError =1
		set @ResultMessage = dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,42)
		
End catch
