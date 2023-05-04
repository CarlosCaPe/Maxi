CREATE procedure [Operation].[st_UpdateProductTransferStatus]
(
    @IdProductTransfer bigint,
    @IdStatus int,
    @TransactionDate datetime,
    @EnterByIdUser int = null,
    @HasError bit out
)
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

begin try
declare @Note nvarchar(max)
select @Note=Statusname from [status] with(nolock) where idstatus=@IdStatus

   if @IdStatus=22 
   begin
       UPDATE [Operation].[ProductTransfer]
       SET 
           [DateOfCancel] = getdate()  
          ,[IdStatus] = @IdStatus   
          ,[TransactionProviderCancelDate] = @TransactionDate  
          ,EnterByIdUserCancel= isnull(@EnterByIdUser   ,EnterByIdUserCancel)
       WHERE 
            IdProductTransfer=@IdProductTransfer;
   end
   else
   begin
       UPDATE [Operation].[ProductTransfer]
       SET           
          [IdStatus] = @IdStatus,
          DateOfStatusChange = getdate(),
          EnterByIdUser= isnull(@EnterByIdUser   ,EnterByIdUser)            
       WHERE 
            IdProductTransfer=@IdProductTransfer;
   end

   set @EnterByIdUser = isnull(@EnterByIdUser,0);

   exec [Operation].[st_SaveChangesToProductTransferLog]
		@IdProductTransfer = @IdProductTransfer,
		@IdStatus = @IdStatus,
		@Note = @Note,
		@IdUser = @EnterByIdUser,
		@CreateNote = 0;

set @HasError=0
end try
Begin Catch                                                                                        
    Set @HasError=1                                                                                     
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('operation.st_UpdateProductTransferStatus',Getdate(),@ErrorMessage)  ;                                                                                          
End Catch