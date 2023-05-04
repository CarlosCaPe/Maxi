
CREATE PROCEDURE [Billpayment].[st_GetRequiredRuleRuleBillpayment]

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
		 , OrderByEntityToValidate 
		from  
		 Billpayment.ValidationRules  Vr with(nolock)
		where 
		 Vr.IdGenericStatus=1
		 and Vr.IdValidator= 4
	 
