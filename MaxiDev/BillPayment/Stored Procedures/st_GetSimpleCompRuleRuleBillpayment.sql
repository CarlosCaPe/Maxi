
CREATE PROCEDURE [Billpayment].[st_GetSimpleCompRuleRuleBillpayment]

AS
/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgent</app>
<Description></Description>

<ChangeLog>
<log Date="28/01/2019" Author="amoreno">Create</log>
</ChangeLog>
********************************************************************/
Set nocount on
		select 
		 IdEntityToValidate
		 , IdStateConfig= isnull(IdStateConfig, 0)
		 , Field
		 , ErrorMessageES
		 , ErrorMessageUS
		 , Field
		 , ComparisonValue
		 , [Type]
		 , Expression		 
		 , OrderByEntityToValidate 
		from  
		 Billpayment.ValidationRules  as  Vr with (nolock)	
		inner join 
		 BillPayment.SimpleComparisonRule as  Sr  with (nolock)	
		on 
		 Sr.IdValidationRule = Vr.IdValidationRule
		where  
		 Vr.IdGenericStatus=1
