CREATE procedure [Corp].[st_GetFaxTrainingConsecutive]
(              
    @IdUser int         
)
as             
/********************************************************************
<Author>Earreola</Author>
<app> </app>
<Description>Create Fax Training Search </Description>

<ChangeLog>
<log Date="2018-10-10" Author="earreola"> Creacion  </log>

</ChangeLog>

*********************************************************************/
Begin try
Set nocount on         

select 
isnull(max(consecutive),0) + 1 as consecutive
from FaxTrainingHistory with(nolock)
where IdUser = @IdUser

End Try                                                                                            

Begin Catch                                                                                        

    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetFaxTrainingConsecutive]',Getdate(),@ErrorMessage)                                                                                            

End Catch 