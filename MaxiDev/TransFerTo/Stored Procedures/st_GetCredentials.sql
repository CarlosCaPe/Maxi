﻿CREATE procedure [TransFerTo].[st_GetCredentials]
as
select [dbo].[GetGlobalAttributeByName]('TToLogin') Login, [dbo].[GetGlobalAttributeByName]('TToToken') Token, [dbo].[GetGlobalAttributeByName]('TToURL') URL,[dbo].[GetGlobalAttributeByName]('TToAction') Action,[dbo].[GetGlobalAttributeByName]('TToTimeOut') TimeOut, [dbo].[GetGlobalAttributeByName]('TransferToShowPromotions') TransferToShowPromotions