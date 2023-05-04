create procedure st_UpdateFileUpload
(
    @idFile int,
    @fileguid nvarchar(max),
    @LastIpChange nvarchar(max),
    @LastNoteChange nvarchar(max),
    @LastUserChange int
)
as
begin try
    update uploadfiles
        set 
            FileGuid=@fileguid,            
            LastChange_LastIpChange=@LastIpChange,
            LastChange_LastNoteChange=@LastNoteChange,
            LastChange_LastUserChange=@LastUserChange,                        
            LastChange_LastDateChange=getdate()
        where
            IdUploadFile=@idFile
end try
begin catch
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select  @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_UpdateFileUpload',Getdate(),@ErrorMessage)
end catch