CREATE PROCEDURE [dbo].[st_SendMobileNotification]
@webUrl NVARCHAR (MAX) NULL, @beneficiaryToken NVARCHAR (MAX) NULL, @customerToken NVARCHAR (MAX) NULL, @beneficiaryFullName NVARCHAR (MAX) NULL, @customerFullName NVARCHAR (MAX) NULL, @statusId INT NULL, @transferId BIGINT NULL, @beneficiaryTypeId INT NULL, @customerTypeId INT NULL, @taskId INT NULL, @hasError BIT NULL OUTPUT, @message NVARCHAR (MAX) NULL OUTPUT
AS EXTERNAL NAME [Boz.MoneyAlertClr].[Boz.MoneyAlertClr.MoneyAlertClr].[SendMobileNotificationAsync]

