-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-05-25
-- Description:	Returns scheme for mobile wallet payment types
-- =============================================
CREATE PROCEDURE [dbo].[st_PayerToMobileWalletBySchemaWithAmount]
	-- Add the parameters for the stored procedure here
	@IdAgent INT,
    @IdAgentSchema INT,
    @Amount MONEY,
    @IsUSD BIT,
	@IdCity INT =  null
AS
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>

<ChangeLog>
<log Date="07/11/2017" Author="Fgonzalez">Add City</log>
<log Date="22/08/2020" Author="jgomez"> CR - M00256</log>
<log Date="17/12/2020" Author="jgomez"> CR - M00328 - Refactor implementacion Redondeo</log>
<log Date="22/12/2020" Author="jcsierra">Show AmountBase Configs </log>
<log Date="11/08/2022" Author="maprado">Add BeneficiaryIdIsRequiered flag from Configs </log>
</ChangeLog>
*********************************************************************/
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    -- Insert statements for procedure here
	
	DECLARE @IniDate DATETIME
	SET @IniDate=GETDATE()

create table #tmp
(
	id int identity(1,1),
	DepositHold	bit,
	Folio	int, 
	IdGenericStatus	int,
	IdPayer	int,
	PayerCode	nvarchar(max),
	PayerName	nvarchar(max),
	IdPayerConfig	int, 
	IdCountryCurrency	int,
	IdGateway	int,
	PayerConfigIdGenericStatus	int,
	IdPaymentType	int,
	SchemaTempSpreadValue	money,
	PayerSpreadValue	money,
	SchemaSpreadValue	money,
	RefExRate	money,
	RefExRateSpecial money,
	RequireBranch	int,
	DivisorExchangeRate	money,
	IdFee	int, 
	Fee Money,
	IdCommission	int,
	IdSpread int,
	Rules xml,
	DisablePayer bit,
	IsSwitchSpecExRateGroup bit,
	IsEnabledScaleRounding bit, -- CR - M00328
	IdScaleRounding INT, -- CR - M00328
	AmountBase		MONEY,
	AmountBaseIsUSD BIT,
	BeneficiaryIdIsRequiered BIT
)

    DECLARE @IdPrimaryAgent int , @IsSwitchSpecExRateGroup bit  -- CR - M00256   

    SELECT @IdPrimaryAgent = IdPrimaryAgent from Agent A with(nolock) inner join AgentGroup AG with(nolock) on A.IdAgentGroup = AG.IdAgentGroup where IdAgent = @IdAgent

    SELECT @IsSwitchSpecExRateGroup = IsSwitchSpecExRateGroup from Agent with(nolock) WHERE IsSwitchSpecExRateGroup = 1 AND IdAgent = @IdPrimaryAgent

	if (@IsSwitchSpecExRateGroup is null)
	BEGIN 
	set @IsSwitchSpecExRateGroup = 0
	end  -- CR - M00256  

	DECLARE @IdPaymentType INT
	SET @IdPaymentType =5 -- MOBILE WALLET

insert into #tmp    
	SELECT  
		[DepositHold]
		, [Folio]
		, [IdGenericStatus]
		, [IdPayer]
		, [PayerCode]
		, [PayerName]
		, [IdPayerConfig]
		, [IdCountryCurrency]
		, [IdGateway]
		, [PayerConfigIdGenericStatus]
		, [IdPaymentType]
		, [SchemaTempSpreadValue]
		, [PayerSpreadValue]
		, CASE WHEN IsSwitchSpecExRateGroup = 0 and ISNULL(L.[IdSpread], 0)>0
							THEN ISNULL((SELECT SD.[SpreadValue]
									FROM [dbo].[SpreadDetail] SD (NOLOCK)
									WHERE SD.[IdSpread] = L.[IdSpread]
										AND CASE WHEN @IsUSD=1 THEN @Amount ELSE @Amount/([SchemaTempSpreadValue]+[PayerSpreadValue]+[RefExRate]+SD.SpreadValue) END BETWEEN SD.[FromAmount] AND SD.[ToAmount]),0)
			 
			 WHEN IsSwitchSpecExRateGroup = 1 and exists (select s.IdPayer from RefExRateByGroup s where s.IdPayer = IdPayer) and ISNULL(l.IdSpread ,0)>0 THEN ISNULL((SELECT MAX(SD.SpreadValue)
											FROM SpreadDetail SD WITH(NOLOCK)
											WHERE SD.IdSpread = l.IdSpread ),0) 
		    WHEN IsSwitchSpecExRateGroup = 1 AND not exists (select s.IdPayer from RefExRateByGroup s where s.IdPayer = IdPayer) and ISNULL(L.[IdSpread], 0)>0
							THEN ISNULL((SELECT SD.[SpreadValue]
									FROM [dbo].[SpreadDetail] SD (NOLOCK)
									WHERE SD.[IdSpread] = L.[IdSpread]
										AND CASE WHEN @IsUSD=1 THEN @Amount ELSE @Amount/([SchemaTempSpreadValue]+[PayerSpreadValue]+[RefExRate]+SD.SpreadValue) END BETWEEN SD.[FromAmount] AND SD.[ToAmount]),0)
														
		 ELSE ISNULL([SchemaSpreadValue],0)
			END [SchemaSpreadValue]
		, [RefExRate]
		, [RefExRateSpecial]     -- CR - M00256    
		, [RequireBranch]
		, [DivisorExchangeRate]
		, [IdFee]
		, [Fee]
		, [IdCommission]
		, L.[IdSpread]
		,null Rules
		,0 DisablePayer
		, IsSwitchSpecExRateGroup  -- CR - M00256
		, IsEnabledScaleRounding -- CR - M00328
		, CASE WHEN IdScaleRounding IS NULL THEN 0 else IdScaleRounding end IdScaleRounding, -- CR - M00328
		L.AmountBase,
		L.ValidateUSDAmount,
		L.BeneficiaryIdIsRequiered
	from (
		SELECT DISTINCT
			PC.[DepositHold]
			, P.[Folio]
			, P.[IdGenericStatus]
			, P.[IdPayer]
			, P.[PayerCode]
			, P.[PayerName]
			, PC.[IdPayerConfig]
			, PC.[IdCountryCurrency]
			, PC.[IdGateway]
			, PC.[IdGenericStatus] [PayerConfigIdGenericStatus]
			, PC.[IdPaymentType]
			, CASE
				WHEN AD.[EndDateTempSpread] > GETDATE() THEN ISNULL(AD.[TempSpread],0)
				ELSE 0
			END [SchemaTempSpreadValue]
			, ISNULL(PC.[SpreadValue],0) [PayerSpreadValue]
			, CASE
				WHEN AD.[IdSpread] IS NULL THEN AD.SpreadValue
				ELSE 0
			END [SchemaSpreadValue]
			, ISNULL(R1.[RefExRate], ISNULL(R2.[RefExRate], ISNULL(R3.[RefExRate],0))) [RefExRate]
			, CASE WHEN @IsSwitchSpecExRateGroup = 1 and R4.IdPayer = P.IdPayer then R4.RefExRateByGroup else 0 End RefExRateSpecial  -- CR - M00256
			, PC.[RequireBranch]
			, C.[DivisorExchangeRate]
			, AD.[IdFee]
			, CASE 
				WHEN ISNULL(F.IdFee ,0)>0 THEN ISNULL((SELECT FD.Fee
												FROM FeeDetail FD WITH(NOLOCK)
												WHERE FD.IdFee = F.IdFee
													AND case 
															when @IsUSD=1 then @Amount 
															else @Amount/((case when AD.EndDateTempSpread>GETDATE() then Isnull(AD.TempSpread,0) else 0 end)+(ISNULL(PC.SpreadValue,0))+(ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))))) 
														end 
														BETWEEN FD.FromAmount AND FD.ToAmount),0) 
				ELSE ISNULL(Fee,0)
				END [Fee]
			, AD.[IdCommission]
			, AD.[IdSpread]
			, CASE WHEN R4.IdAgent = @IdPrimaryAgent AND @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = P.IdPayer then 1 else 0 end IsSwitchSpecExRateGroup -- CR - M00256 
			, CASE WHEN PR.IdPayer = PC.IdPayer AND PR.IdPaymentType = PC.IdPaymentType then 1 else 0  end IsEnabledScaleRounding -- CR - M00328
            , CASE WHEN PR.IdPayer = PC.IdPayer AND PR.IdPaymentType = PC.IdPaymentType then PR.IdScaleRounding else null end IdScaleRounding,  -- CR - M00328 
			sab.AmountBase,
			pab.ValidateUSDAmount,
			PC.BeneficiaryIdIsRequiered
		FROM [dbo].[AgentSchema] A
		JOIN [dbo].[AgentSchemaDetail] AD ON A.[IdAgentSchema]=AD.[IdAgentSchema]
		JOIN [dbo].[PayerConfig] PC ON AD.[IdPayerConfig]=PC.[IdPayerConfig] AND A.[IdCountryCurrency]=PC.[IdCountryCurrency]
		JOIN [dbo].[CountryCurrency] CC ON CC.[IdCountryCurrency]=PC.[IdCountryCurrency]
		JOIN [dbo].[Currency] C ON C.[IdCurrency]=CC.[IdCurrency]
		JOIN [dbo].[Payer] P ON PC.[IdPayer]=P.[IdPayer]
		LEFT JOIN [dbo].[RefExRate] R1 ON R1.[IdCountryCurrency]=A.[IdCountryCurrency] AND R1.[Active]=1 AND R1.[RefExRate]<>0 AND PC.[IdGateway]=R1.[IdGateway] AND P.[IdPayer]=R1.[IdPayer]
		LEFT JOIN [dbo].[RefExRate] R2 ON R2.[IdCountryCurrency]=A.[IdCountryCurrency] AND R2.[Active]=1 AND R2.[RefExRate]<>0 AND PC.[IdGateway]=R2.[IdGateway] AND R2.[IdPayer] IS NULL AND R1.[RefExRate] IS NULL
		LEFT JOIN [dbo].[RefExRate] R3 ON R3.[IdCountryCurrency]=A.[IdCountryCurrency] AND R3.[Active]=1 AND R3.[IdGateway] IS NULL AND R3.[IdPayer] IS NULL AND R1.[RefExRate] IS NULL AND R2.[RefExRate] IS NULL
		LEFT JOIN RefExRateByGroup R4 (nolock) ON R4.IdCountryCurrency = A.IdCountryCurrency and R4.IdPayer = P.IdPayer and R4.IdAgent = @IdPrimaryAgent  -- CR - M00256
		LEFT JOIN PayerRounding PR WITH(NOLOCK) ON PR.IdPayer = PC.IdPayer AND PR.IdPaymentType = PC.IdPaymentType AND PR.IsEnabled = 1  -- CR - M00328
		INNER JOIN Fee F WITH(NOLOCK) ON F.IdFee = AD.IdFee
		INNER JOIN FeeDetail FD WITH(NOLOCK) ON FD.IdFee = F.IdFee
		LEFT JOIN PayerAmountBase pab WITH(NOLOCK) ON pab.IsEnabled = 1 AND pab.IdPayerConfig = pc.IdPayerConfig
		LEFT JOIN ScaleAmountBase sab WITH(NOLOCK) ON sab.IdScaleAmountBase = pab.IdScaleAmountBase          
		WHERE A.[IdAgentSchema]=@IdAgentSchema
			AND PC.[IdGenericStatus]=1 AND P.[IdGenericStatus]=1
			AND PC.[IdPaymentType]=@IdPaymentType
	)L
	ORDER BY [RefExRate]+[PayerSpreadValue]+[SchemaSpreadValue] DESC, [PayerName] ASC

if isnull(@IdCity,0)>0
begin
delete from #tmp where RequireBranch=1 and idpayer not in
(select IdPayer from Branch (nolock) where IdCity=@IdCity and IdPayer in (select IdPayer from #tmp where RequireBranch=1) and idgenericstatus=1)
end	

declare @init int 
declare @tot int 
declare @idpayer int
declare @IdGateway int
declare @GlobalIDUSacurrency int
declare @Fxrate money
declare @Disable bit
declare @Data xml
declare @rules table
(
	IdRule	int,
	RuleName	nvarchar(max),
	amount	money,
	MessageInEnglish	nvarchar(max),
	MessageInSpanish nvarchar(max),
	amountusd money,
	amountmn money,
	exrate money
)


Select @GlobalIDUSacurrency=convert(int,Value) from GlobalAttributes where Name='IdCountryCurrencyDollars'

declare @amountusd money = case when @IsUSD=1 then @Amount else @Amount/18.7 end
declare @amountmn money = case when @IsUSD=1 then @Amount*18.7 else @Amount end


select @init=min(id),@tot=max(id) from #tmp

while(@init<=@tot)
begin

	select 
		@idpayer=IdPayer,
		@IdGateway=IdGateway,
		@Fxrate=SchemaTempSpreadValue+PayerSpreadValue+SchemaSpreadValue+RefExRate ,
		@amountusd = case when @IsUSD=1 then @Amount else @Amount/(SchemaTempSpreadValue+PayerSpreadValue+SchemaSpreadValue+RefExRate) end,
		@amountmn  = case when @IsUSD=1 then @Amount*(SchemaTempSpreadValue+PayerSpreadValue+SchemaSpreadValue+RefExRate) else @Amount end
	from 
		#tmp 
	where 
		id=@init

	insert into @rules
	select IdRule,RuleName,amount,MessageInEnglish,MessageInSpanish,@amountusd amountusd,@amountmn amountmn,@Fxrate Fxrate
	from KYCRule (nolock)
	where  
	action=5 
	and IdGenericStatus=1 and IsExpire=0
	and (TimeInDays=1 or TimeInDays is null) 
	and Symbol='>' 
	and IdPayer=@idpayer
	And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
	AND (IdGateway=@IdGateway or IdGateway is NULL)
	and Amount<case when IdCountryCurrency=@GlobalIDUSacurrency then @amountusd else @amountmn end
	union all
	select IdRule,RuleName,amount,MessageInEnglish,MessageInSpanish,@amountusd amountusd,@amountmn amountmn,@Fxrate Fxrate 
	from KYCRule (nolock)
	where  
	action=5 
	and IdGenericStatus=1 and IsExpire=0
	and (TimeInDays=1 or TimeInDays is null) 
	and Symbol='<'
	and IdPayer=@idpayer
	And (IdPaymentType=@IdPaymenttype or IdPaymentType is NULL)
	AND (IdGateway=@IdGateway or IdGateway is NULL)
	and Amount>case when IdCountryCurrency=@GlobalIDUSacurrency then @amountusd else @amountmn end

	if exists(select top 1 1 from @rules)
	begin
		set @Disable = 1
		set @Data = (select * from @rules FOR XML RAW ('Rule'), ROOT('Rules') )
	end

	if (@Disable = 1)
	begin
		update #tmp set DisablePayer=@Disable,Rules=@Data where id=@init
	end

	set @Disable = 0
	delete from @rules

	set @init=@init+1
	
end


select * from #tmp
order by DisablePayer, RefExRate+PayerSpreadValue+SchemaSpreadValue desc, PayerName asc


END
