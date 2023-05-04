CREATE procedure [dbo].[st_GetFaxTrainingConsecutive]

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
Set nocount on         

select isnull(max(consecutive),0) + 1 as consecutive
  from FaxTrainingHistory with(nolock)
 where IdUser = @IdUser
