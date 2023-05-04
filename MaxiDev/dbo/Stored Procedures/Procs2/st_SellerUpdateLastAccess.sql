create procedure st_SellerUpdateLastAccess
(
    @IdUserSeller int 
)
as
Begin Try
    update seller set DateOfLastAccess=getdate() where IdUserSeller=@IdUserSeller
End Try                                                
Begin Catch	
	Declare @ErrorMessage nvarchar(max)  
	Select @ErrorMessage=ERROR_MESSAGE()
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SellerUpdateLastAccess',Getdate(),@ErrorMessage)                                                
End Catch