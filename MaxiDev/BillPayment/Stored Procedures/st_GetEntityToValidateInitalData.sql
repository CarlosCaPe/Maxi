
CREATE Procedure [billpayment].[st_GetEntityToValidateInitalData]    
   
AS    
Set nocount on  

/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Get EntityToValidate Inital Data - BillPayment </Description>

<ChangeLog>
<log Date="01/14/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/

select IdValidator, ValidatorName, Description from BillPayment.Validator with(nolock)
select IdDataType, DataType,  IsTypeRange from BillPayment.EntityToValidateDataType with(nolock)
select IdExpression, Expression from BillPayment.EntityToValidateExpression with(nolock)


