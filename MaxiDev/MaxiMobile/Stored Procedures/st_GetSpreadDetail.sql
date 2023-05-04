CREATE PROCEDURE [MaxiMobile].[st_GetSpreadDetail]
(
	@id_spread INT
)
as
/********************************************************************
<Author>rgaona</Author>
<app>MaxiAgente</app>
<Description>Obtine los Spread Detail para MaxiAgentMovil</Description>

<ChangeLog>
<log Date="29/04/2019" Author="rgaona">Spread Detail</log>
</ChangeLog>
*********************************************************************/
Begin Try 

	
SELECT SD.IdSpreadDetail,SD.FromAmount,SD.ToAmount,SD.SpreadValue FROM SpreadDetail SD (NOLOCK) WHERE SD.IdSpread = @id_spread ORDER BY FromAmount

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetSpreadDetail]',GETDATE(),@ErrorMessage)
END CATCH
