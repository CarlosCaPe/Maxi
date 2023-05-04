CREATE PROCEDURE [Corp].[st_GetStatesMaxi]
AS

Begin Try

SET NOCOUNT ON;

DECLARE @StateMaxi Table
(
	[Id] int IDENTITY(1,1) NOT NULL,		
	idstate int 
	,statename nvarchar(max)
	,statecode varchar(max)
)

	Insert Into @StateMaxi (idstate, statename, statecode)  Values (0, 'DEFAULT' , 'ALL');

	;WITH CTE_AGENT AS 
	(
		Select 
			Distinct
				AgentState 
		From Agent WITH(Nolock)
	),CTE_STATE_USA AS 
	(
		Select 
			idstate
			,statename
			,statecode 
		From [state] WITH(Nolock)
			Where idcountry=18
	)Insert into @StateMaxi (idstate, statename, statecode)
		Select 
				S.idstate
				,S.statename
				,S.statecode 
			From CTE_AGENT AS A
				Inner Join CTE_STATE_USA AS S On A.AgentState=S.StateCode
			Order by statename;

	Select 
		S.idstate
		,S.statename
		,S.statecode 
	From @StateMaxi AS S
		Order by [Id];

End Try                                                                                            
Begin Catch
	Declare @ErrorMessage NVARCHAR(MAX)                                                                                             
	Select @ErrorMessage=ERROR_MESSAGE()                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('[Corp].[st_GetStatesMaxi]',Getdate(),@ErrorMessage)                                                                                            
End Catch  
