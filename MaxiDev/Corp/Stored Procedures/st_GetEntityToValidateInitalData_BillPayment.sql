CREATE Procedure [Corp].[st_GetEntityToValidateInitalData_BillPayment]    
   
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

select IdValidator, ValidatorName, Description from BillPayment.Validator WITH(NOLOCK)
select IdDataType, DataType, IsTypeRange from BillPayment.EntityToValidateDataType WITH(NOLOCK)
select IdExpression, Expression from BillPayment.EntityToValidateExpression WITH(NOLOCK)



