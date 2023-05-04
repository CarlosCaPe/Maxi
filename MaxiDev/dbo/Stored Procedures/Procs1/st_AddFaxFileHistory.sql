create procedure st_AddFaxFileHistory
(
    @IdQueueFax int,
    @IdFaxType int,
    @FileName nvarchar(max),
    @HasError bit OUTPUT
)
as
Begin Try  
insert into faxFileHistory
(IdQueueFax,IdFaxType,FileName,DateOfCreation,DateOfLastChange,IsDeleted)
values
(@IdQueueFax,@IdFaxType,@FileName,getdate(),getdate(),0)

Set @HasError=0     
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                       
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AddFaxFileHistory',Getdate(),@ErrorMessage)                                                                                            
End Catch      