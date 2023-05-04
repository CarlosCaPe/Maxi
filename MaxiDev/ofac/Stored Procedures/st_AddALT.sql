CREATE procedure Ofac.st_AddALT
(
    @ent_num bigint,
    @alt_num bigint,
    @alt_type nvarchar(100),    
    @alt_PrincipalName nvarchar(2000),
    @alt_FirstLastName nvarchar(2000),    
    @alt_remarks nvarchar(2000)
)
as
Begin Try 
declare @ALT_name nvarchar(2000)
set @ALT_name=@alt_FirstLastName+' '+@alt_PrincipalName

INSERT INTO [dbo].[OFAC_ALT]
           ([ent_num]
           ,[alt_num]
           ,[alt_type]
           ,[alt_name]
           ,[alt_remarks]
           ,alt_PrincipalName
           ,alt_FirstLastName
           )
     VALUES
           (
            @ent_num
           ,@alt_num
           ,@alt_type
           ,@alt_name
           ,@alt_remarks
           ,@alt_PrincipalName
           ,@alt_FirstLastName
           )

End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Ofac.st_AddALT ent_num: '+@ent_num+' alt_num: '+@alt_num,Getdate(),@ErrorMessage)                                                                                            
End Catch
