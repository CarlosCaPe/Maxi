CREATE Procedure [Corp].[st_GetEntityToValidateBillPayment_BillPayment]    
   
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Get EntityToValidate - BillPayment </Description>

<ChangeLog>
<log Date="01/09/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/

 select 
  IdEntityToValidate
  , Name
  , Description
  , IsAllowedToEdit 
 from 
  billpayment.EntityToValidate with (nolock) 
 where IsAllowedToEdit=1


