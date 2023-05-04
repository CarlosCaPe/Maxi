CREATE   procedure [DTOne].[st_GetCredentials]
as
SELECT [dbo].[GetGlobalAttributeByName]('DTOLogin') Login,
[dbo].[GetGlobalAttributeByName]('DTOToken') Token, 
[dbo].[GetGlobalAttributeByName]('DTOURL') URL,
[dbo].[GetGlobalAttributeByName]('TToAction') Action,
[dbo].[GetGlobalAttributeByName]('TToTimeOut') TimeOut, 
[dbo].[GetGlobalAttributeByName]('TransferToShowPromotions') TransferToShowPromotions