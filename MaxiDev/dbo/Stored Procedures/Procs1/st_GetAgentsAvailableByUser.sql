
/********************************************************************
<Author></Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for search screen</Description>

<ChangeLog>
<log Date="21/08/2020" Author="jgomez"> CR - M00256 - Permitir Modificaciones del Tipo de Cambio en Agente</log>
<log Date="29/09/2020" Author="bortega">Parámetro para proceso de Canje de Cheques Ref :: M00248 </log>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [dbo].[st_GetAgentsAvailableByUser]
@idUser int
AS
BEGIN TRY
--SET NOCOUNT ON;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @Agents TABLE
(
	IdAgent int
)


DECLARE @Day INT,
@DateActual datetime = GETDATE(), --CR - M00256
@DateExiration datetime,
@DaysDiference int,
@IdPrimaryAgent int ,
@IsSwitchSpecExRateGroup bit,
@DateExiration2 datetime,
@DaysDiference2 int -- END CR - M00256

set @Day = [dbo].[GetDayOfWeek] (getdate())


IF (exists (select 1 from AgentUser AU (nolock) where AU.IdUser=@idUser))
	BEGIN
		INSERT INTO @Agents (IdAgent)
		SELECT IdAgent
		FROM AgentUser (nolock)
		WHERE IdUser=@idUser
	END
ELSE
	BEGIN
		INSERT INTO @Agents (IdAgent)
		SELECT IdAgent
		FROM Agent (nolock)
		WHERE  IdAgentStatus not in (2,6,5) AND LTRIM(RTRIM(AgentCode)) not like '%-B'
			
	END

IF (exists (select 1 from AgentUser AU (nolock) where AU.IdUser=@idUser))
	BEGIN
    SELECT @DateExiration = ExpirationDateExRateGroup FROM [dbo].[Agent]  A with(nolock)  --CR - M00256
	Inner join [dbo].[AgentGroup] AG with(nolock) ON A.IdAgent = AG.IdPrimaryAgent 
	where IdAgent = (select IdAgent from @Agents)  AND IsSwitchSpecExRateGroup = 1
	SELECT @DaysDiference = DATEDIFF(day, @DateExiration, @DateActual);

    select @IdPrimaryAgent = IdPrimaryAgent from Agent A with(nolock) inner join AgentGroup AG with(nolock) on A.IdAgentGroup = AG.IdAgentGroup where IdAgent = (select IdAgent from @Agents)

    select @IsSwitchSpecExRateGroup = IsSwitchSpecExRateGroup from Agent with(nolock) WHERE IsSwitchSpecExRateGroup = 1 AND IdAgent = @IdPrimaryAgent

	SELECT @DateExiration2 = DateOfLastChange from RefExRateByGroup with(nolock) where IdAgent = @IdPrimaryAgent

	SELECT @DaysDiference2 = DATEDIFF(day, @DateExiration2, @DateActual);

	if (@DaysDiference2 >= 1)
	begin
	delete from RefExRateByGroup where IdAgent = @IdPrimaryAgent
	end

	--if (@DaysDiference >= 1)
	--begin
	--update Agent set IsSwitchSpecExRateGroup = 0 where IdAgent = (select IdAgent from @Agents) 
	--end -- END CR - M00256
	END

SELECT
	A.AgentAddress,
	A.AgentCity,
	A.AgentCode,
	A.AgentName,
	A.AgentState,
	A.IdAgent,
	A.IdAgentPaymentSchema,
	A.SwitchCommission,
	A.CommissionBottom,
	A.CommissionTop,
	A.SwitchExrate,
	A.ExrateBottom,
	A.ExrateTop,
	A.IdAgentStatus,
	A.ShowAgentProfitWhenSendingTransfer,
	A.IdAgentReceiptType,
	A.AgentFax,
	A.AgentPhone,
	A.AgentZipcode,
	A.IdAgentCommunication,
	A.IdAgentBankDeposit,
	A.BlockPhoneTransactions,
	A.MoneyAlertInvitation,
	A.CheckEditMicr,
	 C.StartTime,
	 C.EndTime,	
	Z.TimeZone,
	case
		when O.Phone='(___) ___-____ ' then ''
		else O.Phone
	end OwnerPhone,
	case
		when O.Cel='(___) ___-____ ' then ''
		else O.Cel
	end OwnerCel
	,CASE when AG.IdPrimaryAgent IS not null then A.IsSwitchSpecExRateGroup  else CAST (0 AS bit) end IsSwitchSpecExRateGroup --CR - M00256
	,ISNULL(A.ApplyKYCRules,0) AS ApplyKYCRules   --M00248
FROM Agent A (nolock)
	left join Owner O (nolock) on O.IdOwner =A.IdOwner
	left join CollectionCallendarHours C (nolock) on C.IdAgent = A.IdAgent AND C.DayNumber = @Day
	left join TimeZone Z (nolock)on Z.IdTimeZone = A.IdTimeZone
	left join [dbo].[AgentGroup] AG on AG.IdPrimaryAgent = A.IdAgent
WHERE A.IdAgent in (select IdAgent from @Agents) 
End Try
Begin Catch
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_GetAgentsAvailableByUser]',Getdate(),ERROR_MESSAGE())    
End Catch
