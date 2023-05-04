CREATE PROCEDURE [Corp].[st_GetBlacklistRule]
    
as


   SELECT IdCBLAction, Action FROM [dbo].[CBLAction] WITH(NOLOCK)
	


