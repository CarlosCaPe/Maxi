
CREATE PROCEDURE [Billpayment].[st_GetRangeRuleBillpayment]

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
		 , FromValue
		 , ToValue
		 , [Type]
		 , OrderByEntityToValidate 
		from  
		 Billpayment.ValidationRules  Vr
		inner join 
     Billpayment.RangeRule Rn with (nolock)
		on 
		 Rn.IdValidationRule= Vr.IdValidationRule		
		where 
		-- Vr.idvalidator= 2 
		  Vr.IdGenericStatus=1
