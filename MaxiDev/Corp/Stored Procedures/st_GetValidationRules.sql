CREATE PROCEDURE [Corp].[st_GetValidationRules]
( @IdPayerConfig int)
as
declare @IdGenericStatusEnable int
set @IdGenericStatusEnable= 1

select
	EV.IdEntityToValidate,
	EV.Description EntityDescription,
	VR.IdValidationRule,
	VR.Field,
	VR.ErrorMessageES,
	VR.ErrorMessageUS,
	--VR.IdValidator,
	--V.Description ValidatorDescription,
	VR.OrderByEntityToValidate,
	ISNULL(
			case
				when V.ValidatorName='LengthRule' then ISNULL(VR.Field+' length should be between '+Convert(varchar, LR.Minimum)+' to '+ Convert(varchar,LR.Maximo),'')
				when V.ValidatorName='RangeRule' then ISNULL(VR.Field+' should be between '+ RR.FromValue+' to '+RR.ToValue,'')
				when V.ValidatorName='RegularExpressionRule' then ISNULL(VR.Field+' should fullfil with '+ ER.Pattern+ ' pattern','')
				when V.ValidatorName='RequiredRule' then VR.Field+' is required'
				when V.ValidatorName='SimpleComparison' then ISNULL(VR.Field+' should be '+CR.Expression+' '+Cr.ComparisonValue,'')
			end,'') Description
	
from EntityToValidate EV WITH (NOLOCK)
	inner join ValidationRules VR WITH (NOLOCK) on VR.IdEntityToValidate =EV.IdEntityToValidate
	inner join Validator V WITH (NOLOCK) on V.IdValidator=VR.IdValidator
	left join LengthRule LR WITH (NOLOCK) on LR.IdValidationRule= VR.IdValidationRule
	left join RangeRule RR WITH (NOLOCK) on RR.IdValidationRule =VR.IdValidationRule
	left join RegularExpressionRule ER WITH (NOLOCK) on ER.IdValidationRule= VR.IdValidationRule
	left join SimpleComparisonRule CR WITH (NOLOCK) on CR.IdValidationRule = VR.IdValidationRule
where EV.IsAllowedToEdit=1 and VR.IdGenericStatus=@IdGenericStatusEnable and (VR.IdPayerConfig is null or VR.IdPayerConfig=@IdPayerConfig)
order by EV.IdEntityToValidate, VR.OrderByEntityToValidate


