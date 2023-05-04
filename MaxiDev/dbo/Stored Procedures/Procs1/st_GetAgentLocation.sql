/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="04/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetAgentLocation]
(
	@IdAgent int
)
AS  

Set nocount on;
Begin try
	Select top 1 addressFormatted, latitude, [length] from AgentLocation with(nolock) where idAgent = @IdAgent order by idAgentLocation desc
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentLocation',Getdate(),@ErrorMessage);
End catch
