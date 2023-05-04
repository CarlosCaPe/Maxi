
CREATE PROCEDURE [Billpayment].[st_GetLengthRuleBillpayment]

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
		 , Maximo
		 , Minimum
		 , OrderByEntityToValidate 
		from  
		 Billpayment.ValidationRules  Vr with (nolock)
		inner join 
     Billpayment.LengthRule LR with (nolock)
		on 
		 LR.IdValidationRule= Vr.IdValidationRule		
		where 
		 Vr.idvalidator= 1 and Vr.IdGenericStatus=1
