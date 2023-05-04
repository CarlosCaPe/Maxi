CREATE PROCEDURE [dbo].[st_DeleteUploadFile]

@IdUploadFile int,
@LastUserChange varchar(max),
@HasError bit out
as


begin try

update	[dbo].[UploadFiles] 
		set    
				IdStatus =  0,
				[LastChange_LastUserChange] =  @LastUserChange,
				[LastChange_LastDateChange] =   GETDATE()
		where   IdUploadFile = @IdUploadFile 


		set @HasError=0
end try
begin catch
set @HasError=1

    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DeteleteUploadFile',Getdate(),@ErrorMessage) 

end catch
