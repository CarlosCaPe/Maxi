CREATE Procedure [Corp].[st_AddNoteToTransfer]            
(            
 @IdTransfer Int,            
 @IdUser int,            
 @Note nvarchar(max),            
 @IsSpanishLanguage bit,            
 @TransferDetail XML OUTPUT,              
 @HasError bit out,                  
 @MessageOut varchar(max) out               
)            
AS   
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ;</log>
</ChangeLog>
*********************************************************************/        
Set nocount on             
Begin Try            
Declare @IdTransferDetail int,@IdValue Int        
           
If Exists (Select 1 from TransferClosed WITH(nolock) where IdTransferClosed=@IdTransfer)            
Begin
   EXEC [Corp].[st_MoveBackTransfer] @IdTransfer;
End

/**Cambio para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
 Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer)

 IF @IdTransferDetail IS NOT NULL BEGIN 
 
 	Insert into TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate) values (@IdTransferDetail,3,@IdUser,@Note,GETDATE());   
 	          
 END 
 
 --Get xml representation of transfer's details 
 Select @TransferDetail= [dbo].[fun_GetTransferDetailsXml] (@IdTransfer)

Set @HasError=0                  
Set @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,38)                   
  End Try                                                
Begin Catch                                                
 Set @HasError=1                                       
 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33)                                                 
 Declare @ErrorMessage nvarchar(max)                                                 
 Select @ErrorMessage=ERROR_MESSAGE()                                                
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_AddNoteToTransfer',Getdate(),@ErrorMessage);                                                
End Catch 
   
