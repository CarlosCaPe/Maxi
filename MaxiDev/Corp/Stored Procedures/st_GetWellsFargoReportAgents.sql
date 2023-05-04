CREATE PROCEDURE [Corp].[st_GetWellsFargoReportAgents]
(
@DateFrom datetime = NULL,
@DateTo datetime = NULL
)
AS
--/********************************************************************
--<Author>sNevarez</Author>
--<app>MaxiCorp</app>
--<Description>Agent Report Wells Fargo</Description>

--<ChangeLog>
--<log Date="2017/07/13" Author="snevaarez">S30 :: Creation Store</log>
--<log Date="2019/05/16" Author="adominguez">Requerimiento 051519 :: Agregar campo SubAccount al query</log>
--</ChangeLog>
--********************************************************************/
BEGIN

BEGIN TRY

	IF (@DateFrom IS NULL)
	 SET @DateFrom =  DATEADD(m, DATEDIFF(m, 0, GETDATE()), 0); /*first day of the current month*/
	 
	IF (@DateTo IS NULL)
		SET @DateTo = DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0); /*first day of the next month*/

	select 
		IdAgent
		,AgentCode
		,AgentName
		,s.AgentStatus AS StatusActual, 
		(
			select 
				top 1 DateOfchange 
			from AgentStatusHistory 
			where 
				(DateOfchange>=@DateFrom and DateOfchange<@DateTo and IdAgentStatus=2) 
					and IdAgent=a.idagent
			order by DateOfchange desc
		)
		 AS DateDisable,
		'ACHWellsFargo' BankName
		, a.SubAccount SubAccount
	from agent a
		join AgentStatus s on a.IdAgentStatus=s.IdAgentStatus
	where a.ACHWellsFargo=1 and a.IdAgent in
	(
		select idagent from AgentStatusHistory where (DateOfchange>=@DateFrom and DateOfchange<@DateTo and IdAgentStatus=2)
	)

	union all

	select 
		IdAgent
		,AgentCode
		,AgentName
		,s.AgentStatus AS StatusActual,
		(
			select 
				top 1 DateOfchange 
			from AgentStatusHistory 
			where (DateOfchange>=@DateFrom and DateOfchange<@DateTo and IdAgentStatus=2) 
				and IdAgent=a.idagent 
			order by DateOfchange desc
		) 
		AS DateDisable,
		b.BankName + ',' + b.AccountNumber AS BankName
		, a.SubAccount SubAccount
	from agent a
		join AgentStatus s on a.IdAgentStatus=s.IdAgentStatus
		join AgentBankDeposit b on a.IdAgentBankDeposit=b.IdAgentBankDeposit and b.IdAgentBankDeposit in (6,45,46)
	where a.IdAgent in
	(
		select idagent from AgentStatusHistory where (DateOfchange>=@DateFrom and DateOfchange<@DateTo and IdAgentStatus=2)
	)

END TRY  
BEGIN CATCH 
	  
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage=ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetWellsFargoReportAgents',Getdate(),@ErrorMessage);

END CATCH
	
END
