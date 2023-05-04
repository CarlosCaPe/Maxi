CREATE PROCEDURE [dbo].[st_MaxiAlert_]
@BeginDate dateTime=null
AS            

/********************************************************************
<Author>Juan Diego Arellano Vitela</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="23/02/2018" Author="jdarellano" Name="#1">Se agrega alerta para cambio de contraseña de servicio de cheques de Southside</log>
<log Date="22/05/2018" Author="jdarellano" Name="#2">Se comenta alerta de "AgentBalanceSkips" debido a que existe proceso alterno de ajuste</log>
<log Date="31/08/2018" Author="jdarellano" Name="#3">Se agrega alerta para cambio de contraseña de servicio de cheques de First Midwest</log>
</ChangeLog>
*********************************************************************/     

BEGIN 

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)

	 SET NOCOUNT ON;   
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @tTabc TABLE
( 
   NameValidation nvarchar(max),
   MsgValidation nvarchar(max),
   FixDescription nvarchar(max),
   Fix nvarchar(max)
)

DECLARE @xml NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

------------------
INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlert_AgentLunexWithoutCommition]

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlert_CurrentBalanceWithDecimals]

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlert_TransferInPendingGatewayResponse]

--INSERT INTO @tTabc--#2
--EXEC [dbo].[st_MaxiAlertD_AgentBalanceSkips] @BeginDate

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlertD_BillPaymentWithoutBalance] @BeginDate

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlertD_CancelationsNotRegistered] @BeginDate

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlertD_SendChecksToWellsFargo] @BeginDate

INSERT INTO @tTabc
EXEC [dbo].[st_MaxiAlert_UnitellerConfirmationError] 

INSERT INTO @tTabc
EXEC [st_MaxiAlert_AgentLunexTopUpError]

INSERT INTO @tTabc
EXEC [st_MaxiAlert_ClaimCodeGenerationValidation]

INSERT INTO @tTabc
EXEC [st_MaxiAlert_ChecksPending]

/*---#1---*/
INSERT INTO @tTabc
EXEC [st_MaxiAlertD_ChangePasswordSouthside]

/*---#3---*/
INSERT INTO @tTabc
EXEC [st_MaxiAlertD_ChangePasswordFirstMidwest]
------------------



SET @xml = CAST((
				 SELECT  NameValidation,'										', MsgValidation 
				   FROM @tTabc
			     FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

SET @body ='<html><body><H3>MAXI - ALERTS</H3>
				  <table border = 1> 
				    <tr>
						<th> Alerts </th> </tr>'     
SET @body = @body + @xml +'</table></body></html>'

                      
DECLARE @EmailProfile NVARCHAR(MAX)
SELECT @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'  

 EXEC msdb.dbo.sp_send_dbmail                          

 @profile_name=@EmailProfile,                                                     
 @recipients = 'jcsierra@maxillc.com;lchavez@maxillc.com',
 @body = @body,                                                           
 @body_format ='HTML',
 @subject = 'MAXI - ALERTS'

 --PRINT @body

END




