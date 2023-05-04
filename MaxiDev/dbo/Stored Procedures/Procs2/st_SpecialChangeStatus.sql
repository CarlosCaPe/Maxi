CREATE Procedure [dbo].[st_SpecialChangeStatus]      
(      
@IdTransfer Int,      
@OldIdStatus Int,      
@NewIdStatus Int,      
@Note nvarchar(max),    
@IdReasonForCancel int = null,  
@EnterByIdUser int,      
@IsSpanishLanguage bit,      
@HasError bit out,                
@MessageOut varchar(max) out
)      
AS      
Begin try      
Declare @IdStatus int,@IdAgent Int,@TotalAmountToCorporate money,@AmountInDollars money,  
@AgentCommission money,@Date Datetime,@Folio Int,@Description nvarchar(max),@Country nvarchar(max)      
      
Set @Date=GETDATE()      
      
-- Move transaction to Transfer table-----------      
If Exists (Select 1 from TransferClosed where IdTransferClosed=@IdTransfer)      
  EXEC st_MoveBackTransfer @IdTransfer      
      
-----------------------------------------------------------------------      
     
Select @IdStatus=A.IdStatus,@IdAgent=A.IdAgent,@TotalAmountToCorporate=A.TotalAmountToCorporate,@Folio=A.Folio,@Description=A.CustomerName+' '+A.CustomerFirstLastName,  
@AmountInDollars=A.AmountInDollars,@AgentCommission=A.AgentCommission,@Country=C.CountryCode from Transfer A  
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)  
Join Country C on (B.IdCountry=C.IdCountry)  
where A.IdTransfer=@IdTransfer      
      
If @IdStatus<>@OldIdStatus      
Begin      
Set @HasError=1                
Set @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,39)      
Return        
End      
      
      
If @IdStatus=@NewIdStatus      
Begin      
Set @HasError=1                
Set @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,40)      
Return      
End     


IF (@IdStatus = 25 AND @NewIdStatus = 22)
BEGIN
	SET @HasError = 1                
	SET @MessageOut = 'Transfers in Cancel Stand By status cannot be updated to Cancel status.'--dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 40)      
	RETURN
END

IF (@IdStatus = 72)
BEGIN
	SET @HasError = 1                
	SET @MessageOut = 'Cannot change status to Transfers in Pending by change request.'--dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage, 40)      
	RETURN
END


declare @dateIni datetime
declare @dateFin datetime

 Update Transfer Set IdStatus=@NewIdStatus,DateStatusChange=GETDATE(),IdReasonForCancel=@IdReasonForCancel ,
 @dateIni=DateOfTransfer, @dateFin=DateStatusChange
 Where IdTransfer=@IdTransfer
 Exec st_SaveChangesToTransferLog @IdTransfer,@NewIdStatus,@Note,@EnterByIdUser      
      
------------Balance Id Meaning from table SpecialChangeStatusValidation--------------      
      
--- 1.- Rejected. Return Transfer and Commission      
--- 2.- Cancelled. Return Only Transfer not commission      
--- 3.- Other charges to charge Trnasfer and Commission      
--- 4.- Other Charges to charge only Transfer Not commission      
      
      
      
Declare @BalanceType int      
DECLARE @HasError2 bit,@Message2 varchar(max)
declare @ReturnAllComission int

select @ReturnAllComission=ReturnAllComission from ReasonForCancel where IdReasonForCancel=@IdReasonForCancel      

set @ReturnAllComission=isnull(@ReturnAllComission,case when @NewIdStatus=31 then 1 else 0 end)
      
Set @BalanceType=0      
If Exists (Select 1 from SpecialChangeStatusValidation where FromIdStatus=@OldIdStatus and ToIdStatus=@NewIdStatus)      
 Begin      
     Select @BalanceType=IdBalance from SpecialChangeStatusValidation where FromIdStatus=@OldIdStatus and ToIdStatus=@NewIdStatus      
        
   If @BalanceType=1      
   Begin      
        --Exec st_RejectedCreditToAgentBalance @IdTransfer       
        if (DATEDIFF(minute, @dateIni, @dateFin)<=30)
        begin
            Exec st_RejectedCreditToAgentBalance @IdTransfer
        end
        else
        begin
            if (@ReturnAllComission=1)--validar si se regresa completa la comision
	            Exec st_RejectedCreditToAgentBalance @IdTransfer
            else
                Exec st_CancelCreditToAgentBalance @IdTransfer 
        end
   End      
      
 If @BalanceType=2      
   Begin      
        if (DATEDIFF(minute, @dateIni, @dateFin)<=30)
        begin
             EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer 
        end
        else
        begin
        --Exec st_CancelCreditToAgentBalance @IdTransfer       
            if (@ReturnAllComission=1)--validar si se regresa completa la comision
	            EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer            
            else
                Exec st_CancelCreditToAgentBalance @IdTransfer 
        end
            
   End      
      
 If @BalanceType=3      
   Begin      
           
      --set @Description='st_SpecialSaveOtherCharge'+@Description
   EXEC st_SpecialSaveOtherCharge 0,@IdAgent,@TotalAmountToCorporate,@AgentCommission,@Date,@Description,@Folio,@EnterByIdUser,@Country,      
   @HasError = @HasError2 OUTPUT,@Message = @Message2 OUTPUT      
      
           
   End      
      
 If @BalanceType=4      
   Begin   
   
   if exists(select 1 from dbo.TransferNotAllowedResend where IdTransfer=@IdTransfer)
   Begin
   
   --set @Description='st_SpecialSaveOtherCharge'+@Description

	EXEC st_SpecialSaveOtherCharge 0,@IdAgent,@TotalAmountToCorporate,@AgentCommission,@Date,@Description,@Folio,@EnterByIdUser,@Country,      
   @HasError = @HasError2 OUTPUT,@Message = @Message2 OUTPUT      
      
   
   End
   else
   Begin

    --set @Description='st_SpecialSaveOtherCharge'+@Description      
   EXEC st_SpecialSaveOtherCharge 0,@IdAgent,@AmountInDollars,0,@Date,@Description,@Folio,@EnterByIdUser,@Country,     
     @HasError = @HasError2 OUTPUT,      
     @Message = @Message2 OUTPUT      
     
   End           
           
   End      
      
End       
       
 if (@NewIdStatus in (22,30,31))
 begin
    DECLARE	@HasErrorD bit,	@MessageOutD varchar(max)

    EXEC	[dbo].[st_DismissComplianceNotificationByIdTransfer]
	    	@IdTransfer,
		    1,
		    @HasErrorD OUTPUT,
		    @MessageOutD OUTPUT
 end        
      
Set @HasError=0                
Set @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,44)                 
End Try                                              
Begin Catch                                              
 Set @HasError=1                                     
 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,45)                                               
 Declare @ErrorMessage nvarchar(max)                                               
 Select @ErrorMessage=ERROR_MESSAGE()                                              
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SpecialChangeStatus',Getdate(),@ErrorMessage)                                              
End Catch


