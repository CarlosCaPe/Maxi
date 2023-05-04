CREATE PROCEDURE [dbo].[stGetAgentBalanceReportParams]
	@IdAgents VARCHAR(MAX) = NULL
AS
/********************************************************************
<Author>elopez</Author> 
<app>IRIS Lambda agent balance by email</app> 
<Description>Retrieves agent balance report parameters</Description>

<ChangeLog>
	<log Date="2023/04/26" Author="elopez">Procedure created</log>
</ChangeLog> 
*********************************************************************/
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @Today INT;
        DECLARE @DateTo VARCHAR(12);
        DECLARE @QR_Base64_Image VARCHAR(150);

        SET @Today = dbo.GetToday();
        SET @DateTo = dbo.GetDateTo_SendAgentBalanceByFax();
        SET @QR_Base64_Image = CONCAT(dbo.GetGlobalAttributeByName('QRHandler'), '?id=', dbo.GetGlobalAttributeByName('QRAgentPrefix'));

        SELECT 
            a.IdAgent,
            a.AgentCode,
            a.AgentName,
            dbo.GetDateFrom_SendAgentBalanceByFax(a.IdAgent) AS ReportDateFrom,
            @DateTo AS ReportDateTo,
            CONCAT(@QR_Base64_Image, a.IdAgent) AS ReportQR_Base64_Image,
            a.AgentEmail,
            ISNULL(o.Email, '') AS OwnerEmail,
			ISNULL(SUBSTRING((
                SELECT 
                    ',' + aae.EmailAddress  
                FROM dbo.AgentAdditionalEmail aae WITH(NOLOCK)
                WHERE
                    aae.IdAgent = a.IdAgent AND
                    aae.IdGenericStatus = 1
                FOR XML PATH('')
            ), 2, 99999), '') AS AdditionalEmails
        FROM dbo.Agent a WITH(NOLOCK) 
        INNER JOIN dbo.AgentCurrentBalance acb WITH(NOLOCK) ON
            acb.IdAgent = a.IdAgent 
        INNER JOIN dbo.Owner o WITH(NOLOCK) ON
        	o.IdOwner = a.IdOwner
        WHERE
        	(
                @IdAgents IS NULL OR
                a.IdAgent IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@IdAgents, ','))
            ) AND
            (
                a.DoneOnSundayPayOn = @Today OR
                a.DoneOnMondayPayOn = @Today OR
                a.DoneOnTuesdayPayOn = @Today OR
                a.DoneOnWednesdayPayOn = @Today OR
                a.DoneOnThursdayPayOn = @Today OR
                a.DoneOnFridayPayOn = @Today OR
                a.DoneOnSaturdayPayOn = @Today
            ) AND
            a.IdAgentStatus IN (1, 3, 4, 7) AND
            a.IdAgentCommunication IN (2, 3) AND
            acb.Balance > 0;
	
    END TRY 
	BEGIN CATCH
		INSERT INTO MaxiLS.dbo.ErrorLogForStoreProcedure (
			StoreProcedure,
			ErrorDate,
			ErrorMessage
		)
		VALUES (
			CONCAT(SCHEMA_NAME(), '.', ERROR_PROCEDURE()), 
			GETDATE(), 
			CONCAT(ERROR_MESSAGE(), '|Line: ', CONVERT(varchar(10), ERROR_LINE()))
		);
	END CATCH;
END