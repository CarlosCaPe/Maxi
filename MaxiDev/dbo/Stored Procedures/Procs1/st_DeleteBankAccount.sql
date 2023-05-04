CREATE PROCEDURE [dbo].[st_DeleteBankAccount]    
(   
@IdConfig Int,
@HasError bit out,
@MessageOUT NVARCHAR(MAX) out     
)    
AS    
Set nocount on  

/********************************************************************
<Author> DAlmeida </Author>
<app>Corporate </app>
<Description> Elimina registro</Description>

<ChangeLog>
<log Date="09/13/2017" Author="DAlmeida">Create</log>
</ChangeLog>
*********************************************************************/

Begin       

DELETE FROM AgentBankConfig WHERE IdConfig = @IdConfig;

SET @HasError = 0;
RETURN @HasError;


End 
