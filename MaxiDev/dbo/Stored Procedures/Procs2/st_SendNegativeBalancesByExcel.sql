CREATE PROCEDURE [dbo].[st_SendNegativeBalancesByExcel]
AS
BEGIN TRY
/********************************************************************
<Author> azavala </Author>
<app>SQL Server</app>
<Description>Obtiene los correos para las agencias con saldos negativos
	JOB: [Maxi_NegativeBalance] 
	Programado: Diario
	Horas: 09:00, 16:00, 20:00
</Description>

<ChangeLog>
<log Date="07/06/2018" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
DECLARE @recipients VARCHAR(MAX)
DECLARE @body VARCHAR(MAX)='No-Reply e-mail address'
DECLARE @subject VARCHAR(MAX)='Please review the Agents with Negative Balance'
DECLARE @Counter int = 1
DECLARE @AgentCodes VARCHAR(MAX)

Declare @AgentCode varchar(max)
Declare @AgentName varchar(max)
Declare @Date varchar(max)
Declare @Balance varchar(max)

DECLARE @EmailProfile NVARCHAR(MAX)

DECLARE @MailsNegativeBalance TABLE(
IdEmail int IDENTITY(1,1),
IdEmailCellularLog         INT not NULL,
Number   varchar(MAX) not NULL,
Body     varchar(MAX) not NULL,
Subject  varchar(MAX) not NULL,
DateOfMessage Datetime not null,
AgentCode varchar(MAX) not null
)

DECLARE @AgentsNegativeBalance TABLE(
Id int IDENTITY(1,1),
AgentCode varchar(MAX) not null,
AgentName varchar(MAX) not null,
Balance varchar(MAX) not null,
DateOfMessage Datetime not null
)


	SET NOCOUNT ON;
	Insert into @MailsNegativeBalance (IdEmailCellularLog,Number,Body,Subject,DateOfMessage,AgentCode)
	Select IdEmailCellularLog, Number,Body,Subject, DateOfMessage, AgentCode FROM dbo.EmailCellularLog with(nolock) Where IsNegative=1 and IsSend=0

	set @AgentCodes = (Select Distinct(STUFF((SELECT ','''+AgentCode+'''' from EmailCellularLog Where IsNegative=1 and IsSend=0 FOR XML PATH('')), 1,1,'')) from EmailCellularLog Where IsNegative=1 and IsSend=0)
	set @recipients = (Select distinct STUFF((SELECT Distinct(';'+Number) from EmailCellularLog Where IsNegative=1 and IsSend=0 FOR XML PATH('')), 1,1,'') from EmailCellularLog Where IsNegative=1 and IsSend=0)
	set @recipients = (select REPLACE(@recipients,';;',';'))
	if((select count(1) from @MailsNegativeBalance)>0)
	begin
		
			DECLARE @PathFile varchar(max) = N'H:\ExportSQL\AgentNegativeBalance.csv'
			DECLARE @Cmd nvarchar(4000)

			SET @Cmd = 'bcp "select ''DateOfMessage'',''AgentCode'',''AgentName'',''Balance'' UNION ALL Select convert(varchar(50),E.DateOfMessage,121), a.AgentCode, a.AgentName, case when Balance is null then ''0'' else Convert(varchar,Balance) end as Balance	From [dbo].[Agent] a with(nolock) left join [dbo].[AgentCurrentBalance] acb with(nolock) on a.IdAgent = acb.IdAgent inner join dbo.EmailCellularLog E with(nolock) on E.AgentCode=a.AgentCode where a.AgentCode IN ('+@AgentCodes+') and E.IsSend = 0 and IsNegative = 1 and acb.Balance < 0 " queryout "' + @PathFile + '" -d Maxi -T -c -t,'
			EXEC xp_cmdshell @Cmd

			SELECT @EmailProfile = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler'

			EXEC [msdb].[dbo].sp_send_dbmail
			@profile_name = @EmailProfile,
			@recipients = @recipients,
			@body = @body,
			@subject = @subject,
			@file_attachments=@PathFile

			update t1 set t1.IsSend = 1 from dbo.EmailCellularLog T1 with(nolock) inner join @MailsNegativeBalance T2 on T1.IdEmailCellularLog=T2.IdEmailCellularLog

	end
	

END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(MAX)
		SELECT @ErrorMessage = ERROR_MESSAGE() + CONVERT(varchar(max), ERROR_LINE())
		INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_SendNegativeBalancesByExcel', GETDATE(), @ErrorMessage)
END CATCH
