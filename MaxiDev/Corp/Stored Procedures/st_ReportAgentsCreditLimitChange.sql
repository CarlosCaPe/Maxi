CREATE PROCEDURE [Corp].[st_ReportAgentsCreditLimitChange]
    @dateStart date,
	@dateEnd date
AS

BEGIN

--DECLARE @dateStart DATETIME = '2016-01-26'
--DECLARE @dateEnd DATETIME = '2016-01-26'

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET DATEFORMAT YMD;

SET @dateStart = dbo.RemoveTimeFromDatetime(@dateStart)
SET @dateEnd = dbo.RemoveTimeFromDatetime(@dateEnd)+1

		SELECT AgentCode, AgentName, Name,	
			   CreditLimit,	CreditAdd, CreditLimitSuggested,	
			   Coments,	Fecha, NombreUsuario,
			   ROW_NUMBER()  OVER (PARTITION BY AgentCode ORDER BY Fecha DESC) rw
		  INTO #tData
		  FROM (
				SELECT 
						a.AgentCode,
						a.AgentName,
						ac.Name,
						CAST(0.0 as money) CreditLimit,
						CAST(0.0 as money) CreditAdd, 
						ISNULL(ch.CreditAmount,0.0) CreditLimitSuggested,
						ch.NoteCreditAmountChange Coments,
						ch.DateOfLastChange Fecha,
						UPPER(u.UserName) NombreUsuario
				   FROM AgentCreditLimitHistory ch
				  INNER JOIN Agent a
					 ON ch.IdAgent = a.IdAgent
				  INNER JOIN AgentClass ac
					 ON a.IdAgentClass = ac.IdAgentClass
				  INNER JOIN Users u
					 ON u.IdUser = ch.EnterByIdUser	
			   ) Dat
		  ORDER BY Fecha desc
--------------------------------------------------------
		UPDATE ec SET ec.CreditLimit = ISNULL(ec2.CreditLimitSuggested,0.0) 
		  FROM #tData ec
		 LEFT JOIN #tData ec2
		    ON ec.AgentCode = ec2.AgentCode
		   AND ec.rw = ec2.rw-1 
----------------------------------------------------------
		UPDATE ec SET ec.CreditAdd =  CreditLimitSuggested - CreditLimit
        FROM #tData ec
--------------------------------------------------------
	   SELECT AgentCode, AgentName, Name,	
			  CreditLimit,	CreditAdd, CreditLimitSuggested,	
			  Coments, 
			  Fecha Fecha, 
			  NombreUsuario 
		 FROM #tData
	    WHERE Fecha>= @dateStart 
		 AND  Fecha < @dateEnd
	    ORDER BY AgentCode, Fecha desc

		drop table #tData

END	  


