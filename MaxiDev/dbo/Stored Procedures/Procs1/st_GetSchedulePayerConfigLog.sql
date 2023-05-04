CREATE PROCEDURE [dbo].[st_GetSchedulePayerConfigLog]
(
    @IdPayerConfig int
)
AS
/********************************************************************
<Author>Mhinojo</Author>
<app>MaxiCorp</app>
<Description>To show log info Schedule Payer Config</Description>

<ChangeLog>
<log Date="12/09/2017" Author="mhinojo">S38_2017: Get log info </log>
</ChangeLog>
********************************************************************/
SELECT        
PC.IdPayerConfigScheduleLog, 
PC.DateOfChange AS DateOfLastChange, 
PC.IdUserWhoEdited AS EnterByIdUser, 
PC.IdPayerConfig, 
CAST(PC.StartTime AS datetime) AS StartTime, 
CAST(PC.EndTime AS datetime) AS EndTime, 
CASE 
WHEN PC.StartTime IS NULL AND PC.EndTime IS NULL THEN 'Schedule Disabled'
ELSE CONVERT(VARCHAR(15), PC.StartTime, 100) + ' - ' + CONVERT(VARCHAR(15), PC.EndTime, 100) END AS Schedule, 
U.FirstName + ' ' + U.LastName + ' ' + U.SecondLastName AS UserName
FROM       [MAXILOG].[dbo].PayerConfigScheduleLog AS PC INNER JOIN
Users AS U ON PC.IdUserWhoEdited = U.IdUser
WHERE        (PC.IdPayerConfig = @IdPayerConfig)
