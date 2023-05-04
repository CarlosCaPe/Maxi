
CREATE Procedure [BillPayment].[st_UpdateStatusValidationRulesBillPayment]    
   (  
     @IdValidationRule int    
     , @idStauts int 
     , @idUser int
   )
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Set Validation Rules BillPayment </Description>

<ChangeLog>
<log Date="01/15/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/
                
  update 
   BillPayment.ValidationRules 
  set    
    IdGenericStatus=@idStauts 
  , IdUser=@idUser
  , LastChange = Getdate()
   where IdValidationRule=@IdValidationRule
