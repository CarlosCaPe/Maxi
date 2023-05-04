
CREATE PROCEDURE [Billpayment].[st_GetRegularExpressionRuleBillpayment]

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
		 , Pattern
		 , OrderByEntityToValidate 
		from  
		 Billpayment.ValidationRules  Vr with(nolock)
		inner join 
     Billpayment.RegularExpressionRule as Rn  with (nolock)
		on 
		 Rn.IdValidationRule= Vr.IdValidationRule		
		where 
		 --Vr.idvalidator= 3 and 
		 Vr.IdGenericStatus=1
