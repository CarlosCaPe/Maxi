CREATE procedure [Corp].[st_InsertFaxTrainingHistory]

(              
@IdAgent int,
@IdUser int,
@FileName nvarchar(max),
@Note nvarchar(max),
@Consecutive int,
@HasError bit out
)

as             
/********************************************************************
<Author>Earreola</Author>
<app> </app>
<Description>Insert fax training history </Description>

<ChangeLog>
<log Date="2018-10-10" Author="earreola"> insert  </log>

</ChangeLog>

*********************************************************************/
begin try         

INSERT INTO [dbo].[FaxTrainingHistory]
           ([IdAgent]
           ,[IdUser]
           ,[FileName]
		   ,[Note]
           ,[Consecutive]
           ,[DateOfCreation]
           ,[DateOfApplication])
     VALUES
           (@IdAgent
           ,@IdUser
           ,@FileName
		   ,@Note
           ,@Consecutive
           ,getdate()
           ,NULL)

set @HasError=0

End Try                                                                                            

Begin Catch                                                                                        

    Set @HasError=1                                                                                       

    Declare @ErrorMessage nvarchar(max)                                                                                             

    Select @ErrorMessage=ERROR_MESSAGE()                                             

    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_InsertFaxTrainingHistory',Getdate(),@ErrorMessage)                                                                                            

End Catch 