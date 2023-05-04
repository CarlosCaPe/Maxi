

CREATE PROCEDURE [dbo].[st_MaxiAlert_ClaimCodeGenerationValidation]
AS            
BEGIN 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


select 
	'Consecutivo para generacion de claimcode esta por llegar a su fin' NameValidation,
	'PayerCode:'+payer_name+'; CurrentNumber:'+ISNULL(CAST(payer_current_number AS  VARCHAR), '')+'; WereAvailable:'+convert(varchar,WereAvailable)+'; Available:'+convert(varchar,Available)+';  DisponiblePorcent:'+convert(varchar,ROUND( CAST( Available as float) * 100 /WereAvailable,2))+'; WereAvailable:'+convert(varchar,WereAvailable)+'; ClaimCodeType:'+convert(varchar,ClaimCodeType) MsgValidation,
	'Revisar' FixDescription,
	'' Fix
	--,payer_name, payer_current_number,  WereAvailable, Available, ROUND( CAST( Available as float) * 100 /WereAvailable,2) DisponiblePorcent , ClaimCodeType
from 
(

	select payer_name, payer_current_number, convert(bigint, REPLICATE('9', 6)) WereAvailable --payer_fixed_length=0 minimo deja el numero en 6 posisiones
			,convert(bigint, REPLICATE('9', 6))- payer_current_number Available, 1 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=0 and payer_fixed_length=0 and payer_include_prefix=1 and payer_fixed_range=0	
	union all

	select payer_name,payer_current_number, payer_max_range- payer_min_range WereAvailable
			, payer_max_range- payer_current_number Available, 2 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=0 and payer_fixed_length=0 and payer_include_prefix=0 and payer_fixed_range=1
		and payer_min_range>=1000000
	union all

	select payer_name, payer_current_number, convert(bigint, REPLICATE('9', payer_length_no-2-len(payer_prefix))) WereAvailable 
			,convert(bigint, REPLICATE('9', payer_length_no-2-len(payer_prefix)))- payer_current_number Available , 3 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=0 and payer_fixed_length=1 and payer_include_prefix=1 and payer_fixed_range=0
	union all

	select payer_name, payer_current_number, convert(bigint, REPLICATE('9', payer_length_no-2-len(payer_prefix))) WereAvailable 
			,convert(bigint, REPLICATE('9', payer_length_no-2-len(payer_prefix)))- payer_current_number Available, 4 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=0 and payer_fixed_length=1 and payer_include_prefix=1 and payer_fixed_range=1
		and payer_min_range=0 and payer_max_range= convert(bigint, REPLICATE('9', payer_length_no-2-len(payer_prefix)))
	union all

	select payer_name, payer_current_number, payer_max_range- payer_min_range WereAvailable
			, payer_max_range- payer_current_number Available, 5 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=1 and payer_fixed_range=1
		and payer_min_range>=1000000
	union all

	select payer_name, payer_current_number, convert(int, REPLICATE('9', 6)) WereAvailable --payer_fixed_length=0 minimo deja el numero en 6 posisiones
			,convert(int, REPLICATE('9', 6))- payer_current_number Available, 6 ClaimCodeType
	from TNC_CLAIM_CODE_PAYERS 
	where payer_random_characters=1 and payer_fixed_range=0
	union all
		
	select PayerCode payer_name, Folio payer_current_number, 999999 WereAvailable
		,999999 -Folio Available, 7 ClaimCodeType
	from Payer where payercode = 'BBV' 
)L
where payer_current_number!=0 and payer_name not in ('1473','2600', 'BNRTU') and ROUND( CAST( Available as float) * 100 /WereAvailable,2)<=5



end