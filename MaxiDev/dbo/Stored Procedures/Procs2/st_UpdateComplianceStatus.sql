
CREATE PROCEDURE [dbo].[st_UpdateComplianceStatus]                  
 (                  
 @EnterByIdUser int,                  
 @IsSpanishLanguage bit,                  
 @IdTransfer int,                  
 @Note nvarchar(max),         
 @StatusHold int,        
 @NewIdStatus int,        
 @HasError bit out,        
 @Message varchar(max) out                  
 )                  
 as                  

 /********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

 Set nocount on        
 Begin Try                
 Declare @IdStatus int                  
                   
 Select @IdStatus=IdStatus  From [dbo].[Transfer] WITH(NOLOCK) where IdTransfer=@IdTransfer         

if @StatusHold = 3
Begin
	declare @IsRelease bit
	if @NewIdStatus= 4
	begin set @IsRelease = 1
	end else begin set @IsRelease =0 end
	exec [dbo].st_UpdateVerifyHold @EnterByIdUser, @IsSpanishLanguage, @IdTransfer, @Note, @StatusHold, @IsRelease,
	@HasError = @HasError OUTPUT,
	@Message = @Message OUTPUT

End
Else
Begin
	 If Exists (        
	 Select 1 from [dbo].ValidTransferStatusTransition WITH(NOLOCK) 
	 where FromIdStatus=@IdStatus and         
	 FromIdStatus=@StatusHold and         
	 ToIdStatus=@NewIdStatus        
	 )        
	 Begin          
		Update [dbo].[Transfer] Set IdStatus=@NewIdStatus,DateStatusChange=GETDATE() Where IdTransfer=@IdTransfer                      
		If @NewIdStatus=31    
		Begin    
			Exec [dbo].st_RejectedCreditToAgentBalance @IdTransfer  
		End  
		If @NewIdStatus=22    
		Begin    
			Exec [dbo].st_CancelCreditToAgentBalance @IdTransfer    
		End  
		Exec [dbo].st_SaveChangesToTransferLog @IdTransfer,@NewIdStatus,@Note,@EnterByIdUser     
                
		Exec [dbo].st_DismissComplianceNotificationByIdTransfer @IdTransfer, @IsSpanishLanguage, @HasError out, @Message out  
		
		Select  @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,30)                    
		Set @HasError=0            
	 End          
	 Else        
	 Begin        
		Select  @Message=dbo.GetMessageFromLenguajeResorces(@IsSpanishLanguage,31)                    
		Set @HasError=1        
	 End        
End          
                                          
End Try                                      
Begin Catch                                      
 Set @HasError=1                             
 Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                       
 Declare @ErrorMessage nvarchar(max)                                       
 Select @ErrorMessage=ERROR_MESSAGE()                                      
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateComplianceStatus',Getdate(),@ErrorMessage)                                      
End Catch

