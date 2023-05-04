CREATE procedure Ofac.st_AddSDN
(
    @ent_num  bigint,
    @SDN_PrincipalName nvarchar(4000),
    @SDN_FirstLastName nvarchar(4000),    
    @SDN_type nvarchar(200),
    @program nvarchar(200),
    @title nvarchar(200),
    @call_sign nvarchar(200),
    @vess_type nvarchar(200),
    @tonnage nvarchar(200),
    @GRT nvarchar(200),
    @vess_flag nvarchar(200),
    @vess_owner nvarchar(400),
    @remarks nvarchar(4000)
)
as
Begin Try 
declare @SDN_name nvarchar(4000)

set @SDN_name=@SDN_FirstLastName+' '+@SDN_PrincipalName


INSERT INTO [dbo].[OFAC_SDN]
           ([ent_num]
           ,[SDN_name]
           ,[SDN_type]
           ,[program]
           ,[title]
           ,[call_sign]
           ,[vess_type]
           ,[tonnage]
           ,[GRT]
           ,[vess_flag]
           ,[vess_owner]
           ,[remarks]
           ,SDN_PrincipalName
           ,SDN_FirstLastName
           )
     VALUES
           (
            @ent_num
           ,@SDN_name
           ,@SDN_type
           ,@program
           ,@title
           ,@call_sign
           ,@vess_type
           ,@tonnage
           ,@GRT
           ,@vess_flag
           ,@vess_owner
           ,@remarks
           ,@SDN_PrincipalName
           ,@SDN_FirstLastName
           )

End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Ofac.st_AddSDN ENTNUM: '+@ent_num,Getdate(),@ErrorMessage)                                                                                            
End Catch
