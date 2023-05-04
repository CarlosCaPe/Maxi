CREATE PROCEDURE [dbo].[st_GetAgentCreditSuggest]
as
/********************************************************************
<Author></Author>
<app></app>
<Description>Obtiene agencias candidatas a reduccion de credito</Description>

<ChangeLog>
<log Date="19/07/2018" Author="snevarez"> CO_003_SuggestCreditLimit </log>
<log Date="02/11/2018" Author="jdarellano" Name="#2">Ticket 1569.- Se aplica filtro para que tome agencias solo en estatus "Enabled" y "Suspended"</log>
</ChangeLog>
*********************************************************************/
Begin try

SET NOCOUNT ON;   

    SELECT
	   ACS.IdAgentCreditSuggest,
	   ACS.IdAgent,
	   A.AgentCode,
	   A.AgentName,
	   AC.[Name] AS AgentClass,
	   ACS.CreditLimit,
	   ACS.Margin,
	   ACS.Suggested
     FROM [dbo].[AgentCreditSuggest] AS ACS With(NoLock)
		  Inner Join Agent AS A With(NoLock) On ACS.IdAgent = A.IdAgent
		  Inner Join AgentClass AS AC With(NoLock) On A.IdAgentClass = AC.IdAgentClass
	   WHERE
		  ACS.Suggested < ACS.CreditLimit /*Agregar un filtro en donde el valor sugerido no igual o más alto al límite actual, ya que el objetivo principal es bajar el límite de crédito.*/
		  AND ACS.IsApproved IS NULL
		  AND A.IdAgentStatus in (1,3)--#2
	   ORDER BY A.AgentCode DESC;

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into Soporte.InfoLogForStoreProcedure (StoreProcedure,InfoDate,InfoMessage)Values('dbo.st_GetAgentCreditSuggest',Getdate(),@ErrorMessage);
End Catch
