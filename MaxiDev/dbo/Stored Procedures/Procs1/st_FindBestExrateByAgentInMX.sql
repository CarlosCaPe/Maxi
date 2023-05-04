/********************************************************************
<Author>Unknow</Author>
<app>ReportServer</app>
<Description>Best ExRate</Description>

<ChangeLog>
<log Date="29/01/2019" Author="azavala">se valida si cuenta con spread variable y toma el mayor ordenandolo de la misma manera - Ref: 29012019-azavala</log>
<log Date="22/08/2020" Author="jgomez"> CR - M00256</log></log>
</ChangeLog>
*********************************************************************/
CREATE Procedure [dbo].[st_FindBestExrateByAgentInMX]  
(  
@IdAgent int,  
@IdPayer Int,  
@ExRate money output,  
@PayerLogo nvarchar(max) output,  
@PayerName nvarchar(max) output  
)  
As  
Set nocount on
BEGIN TRY
DECLARE @DateActual datetime = GETDATE(), -- CR - M00256
	@DateExiration datetime,
	@DaysDiference int,
    @IdPrimaryAgent int ,
    @IsSwitchSpecExRateGroup bit

    select @IdPrimaryAgent = IdPrimaryAgent from Agent A with(nolock) inner join AgentGroup AG with(nolock) on A.IdAgentGroup = AG.IdAgentGroup where IdAgent = @IdAgent

    select @IsSwitchSpecExRateGroup = IsSwitchSpecExRateGroup from Agent with(nolock) WHERE IsSwitchSpecExRateGroup = 1 AND IdAgent = @IdPrimaryAgent

	SELECT @DateExiration = ExpirationDateExRateGroup from Agent with(nolock) where IdAgent = @IdPrimaryAgent AND IsSwitchSpecExRateGroup = 1
	SELECT @DaysDiference = DATEDIFF(day, @DateExiration, @DateActual);

	--if (@DaysDiference >= 1)
	--begin
	--update Agent set IsSwitchSpecExRateGroup = 0 where IdAgent = @IdPrimaryAgent
	--end -- END CR - M00256

	DECLARE @IniDate DATETIME
			,@SpreadValue MONEY
	SET @IniDate=GETDATE()
	SET @SpreadValue=300  
  
	Declare @MexicanPesos int  
	Select @MexicanPesos=dbo.GetGlobalAttributeByName('IdCountryCurrencyMexicoPesos')  
  
	SELECT TOP 1 @ExRate=(CASE WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then R4.RefExRateByGroup else
	ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) END
					+CASE WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then 0 else d.SpreadValue end 
					+ CASE WHEN ISNULL(C.IdSpread ,0)>0
						THEN (SELECT ISNULL(MAX(SD.SpreadValue),0) --29012019-azavala
								FROM SpreadDetail SD (NOLOCK)
								WHERE SD.IdSpread = C.IdSpread
									/*AND @SpreadValue BETWEEN SD.FromAmount AND SD.ToAmount*/)
						WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then 0
						ELSE ISNULL(C.SpreadValue,0) 
						END
					+ case when C.EndDateTempSpread>GETDATE() Then C.TempSpread Else 0 End) 
				,@PayerLogo=Isnull(E.PayerLogo,'NotSelected.jpg')
				,@PayerName=E.PayerName 
	FROM AgentSchema B
	--from RelationAgentSchema A  
	--Join AgentSchema B on (A.IdAgentSchema=B.IdAgentSchema)  
	Join AgentSchemaDetail C on (C.IdAgentSchema=B.IdAgentSchema)  
	Join PayerConfig D on (D.IdPayerConfig=C.IdPayerConfig)  and D.Idgenericstatus=1
	Join Payer E on (E.IdPayer=D.IdPayer)  
	--B.IdCountryCurrency,D.IdGateway,D.IdPayer
	LEFT JOIN RefExRate R1 ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and D.IdGateway=R1.IdGateway and D.IdPayer=R1.IdPayer  
	LEFT JOIN RefExRate R2 ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and D.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
	LEFT JOIN RefExRate R3 ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
	LEFT JOIN RefExRateByGroup R4 (nolock) ON R4.IdAgent = @IdPrimaryAgent AND R4.IdCountryCurrency = B.IdCountryCurrency AND R4.IdPayer = E.IdPayer -- CR - M00256
	WHERE B.IdAgent=@IdAgent and B.IdCountryCurrency=@MexicanPesos and D.IdPayer=@IdPayer  and Isnull(E.Idgenericstatus,0)=1 and D.IdPaymentType in (1,4)  and B.IdGenericStatus=1
	and d.IdPaymentType in (1,4,3)
	ORDER BY CASE WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then R4.RefExRateByGroup else
	ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) END
	+CASE WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then 0 else d.SpreadValue end 
	+CASE WHEN ISNULL(C.IdSpread ,0)>0
						THEN (SELECT ISNULL(MAX(SD.SpreadValue),0) --29012019-azavala
								FROM SpreadDetail SD (NOLOCK)
								WHERE SD.IdSpread = C.IdSpread
									/*AND @SpreadValue BETWEEN SD.FromAmount AND SD.ToAmount*/)
						WHEN @IsSwitchSpecExRateGroup = 1 AND R4.IdPayer = E.IdPayer then 0
						ELSE ISNULL(C.SpreadValue,0) 
						END
						+ case when C.EndDateTempSpread>GETDATE() Then C.TempSpread Else 0 End DESC
End Try
Begin Catch
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_FindBestExrateByAgentInMX]',Getdate(),ERROR_MESSAGE())    
End Catch
