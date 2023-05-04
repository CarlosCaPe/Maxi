CREATE Procedure [Corp].[st_GetFieldToValidateBillPayment_BillPayment]    
   
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Get FieldToValidatet - Bank </Description>

<ChangeLog>
<log Date="01/09/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/

 select 
  IdFieldToVAlidate
  , IdEntityToValidate
  , Name
  , [Description] 
 from 
  billpayment.FieldToValidate with (nolock) 



