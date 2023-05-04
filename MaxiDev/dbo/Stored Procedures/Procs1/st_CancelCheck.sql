Create procedure st_CancelCheck
@IdCheck int,
@UserId int,
@CheckNewStatus int
as

Begin
	Exec Checks.[st_SaveChangesToCheckLog] @IdCheck,@CheckNewStatus,'Cancelled',@UserId --- Log de validación de Multiholds  
	Update checks Set IdStatus=30,DateStatusChange=GETDATE() Where IdCheck=@IdCheck  
End