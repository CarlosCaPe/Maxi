
CREATE procedure Billpayment.st_GetValidationRules(@idState int,@IdValidationRule int)
as
/********************************************************************
<Author> Amoreno </Author>
<app>Corporate </app>
<Description> Get ValidationRules - BillPayment </Description>

<ChangeLog>
<log Date="01/10/2019" Author="Amoreno">Create</log>
</ChangeLog>
*********************************************************************/

declare @IdGenericStatusEnable int
set @IdGenericStatusEnable= 1

 if (@idState is null)
  set @IdGenericStatusEnable =null

select
	 EV.IdEntityToValidate
	, EV.[Description] EntityDescription
	, VR.Field
	, VR.IdValidationRule
	, V.IdValidator
  , V.[Description] as [Validator]
  , IdStateConfig = isnull(VR.IdStateConfig, 0)
  , Vr.IdGenericStatus
 	, VR.OrderByEntityToValidate
	, VR.ErrorMessageES
	, VR.ErrorMessageUS
	, ISNULL(
	 		case
	 			when V.ValidatorName='LengthRule' then ISNULL(VR.Field+' length should be between '+Convert(varchar, LR.Minimum)+' to '+ Convert(varchar,LR.Maximo),'')
	 			when V.ValidatorName='RangeRule' then ISNULL(VR.Field+' should be between '+ RR.FromValue+' to '+RR.ToValue,'')
	 			when V.ValidatorName='RegularExpressionRule' then ISNULL(VR.Field+' should fullfil with '+ ER.Pattern+ ' pattern','')
	 			when V.ValidatorName='RequiredRule' then VR.Field+' is required'
	 			when V.ValidatorName='SimpleComparison' then ISNULL(VR.Field+' should be '+CR.Expression+' '+Cr.ComparisonValue,'')
	 		end,'') Description
	, Minimum         =	isnull(LR.Minimum        ,0)
	, Maximo          =	isnull(LR.Maximo         ,0)
	, FromValue       =	isnull(RR.FromValue      ,'')
	, ToValue         =	isnull(RR.ToValue        ,'')
	, Type            =	isnull(RR.Type           ,'')
	, Pattern         =	isnull(ER.Pattern        ,'')
	, ComparisonValue =	isnull(CR.ComparisonValue,'')
	, TypeExpression= isnull(CR.[Type], '')
	, Expression= isnull(CR.Expression,'')

 into #temp2	
from Billpayment.EntityToValidate EV 
	inner join Billpayment.ValidationRules VR on VR.IdEntityToValidate =EV.IdEntityToValidate
	inner join Billpayment.Validator V on V.IdValidator=VR.IdValidator
	left join Billpayment.LengthRule LR on LR.IdValidationRule= VR.IdValidationRule
	left join Billpayment.RangeRule RR on RR.IdValidationRule =VR.IdValidationRule
	left join Billpayment.RegularExpressionRule ER on ER.IdValidationRule= VR.IdValidationRule
	left join Billpayment.SimpleComparisonRule CR on CR.IdValidationRule = VR.IdValidationRule
where EV.IsAllowedToEdit=1 
 --and  VR.IdGenericStatus = isnull(@IdGenericStatusEnable, VR.IdGenericStatus)
order by EV.IdEntityToValidate, VR.OrderByEntityToValidate

select * from #temp2 where IdStateConfig = isnull(@idState, IdStateConfig) and IdValidationRule = isnull(@IdValidationRule, IdValidationRule)

drop table #temp2
