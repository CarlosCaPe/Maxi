create procedure st_ConfirmDeletedFaxFile
(
    @XMLFax xml,
    @HasError bit OUTPUT
)
as
Begin Try  

SELECT C.value('@ID','int') IdFaxFile into #tmp
FROM @XMLFax.nodes('/FaxFile/IdFaxFile') T(c)

update [FaxFileHistory] set dateoflastchange=getdate(),isdeleted=1 where idFaxFileHistory in (select IdFaxFile from #tmp)
Set @HasError=0

End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                       
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_ConfirmDeletedFaxFile',Getdate(),@ErrorMessage)                                                                                            
End Catch      