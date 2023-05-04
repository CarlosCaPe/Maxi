CREATE PROCEDURE [Corp].[st_UpdateCheckMicr]
(
	@IdCheck 					INT, 
	@MicrAuxOnUs 				NVARCHAR(MAX), 
	@RoutingNumber 				NVARCHAR(MAX), 
	@MicrOnUs 					NVARCHAR(MAX), 
	@MicrAmount 				NVARCHAR(MAX),
	@Account 					NVARCHAR(MAX),
	@MicrManual 				NVARCHAR(MAX),
	@MicrRoutingTransitNumber 	NVARCHAR(MAX),
	@CheckNumber 				NVARCHAR(MAX),
	@EnteredByIdUser 			INT,
	@isDuplicate 				bit OUTPUT,
	@FolioDuplicated 			INT = NULL OUTPUT
)
AS
/********************************************************************
<Author>Miguel Angel Hinojo </Author>
<app>MaxiCorp</app>
<Description>Update Micr Checks</Description>

<ChangeLog>
<log Date="30/05/2017" Author="mhinojo">Create Store Procedure</log>
<log Date="13/06/2017" Author="mdelgado">Validation of duplicated micr</log>
<log Date="01/09/2017" Author="mhinojo">Show folio for duplicated checks</log>
<log Date="14/11/2018" Author="jmolina">Valida el monto maximo por agencia en Micr #1</log>
<log Date="18/05/2021" Author="cagarcia">Se agrega parametro @EnteredByIdUser a la llamada al sp Corp.[st_SaveChangesToCheckLog_Checks]</log>
</ChangeLog>
********************************************************************/
BEGIN
	BEGIN TRY
		--#1
		DECLARE  @IdAgent int
		SELECT @IdAgent = IdAgent FROM dbo.Checks WITH(NOLOCK) WHERE 1 = 1 AND IdCheck = @IdCheck
		--#1

		SET @isDuplicate = 0

		--IF (@MicrAmount = '') --#1
		IF (@MicrAmount = '' OR @MicrAmount > (SELECT  MAX(FC.ToAmount) FROM FeeChecks AS F WITH(NOLOCK) inner JOIN FeeChecksDetail AS FC WITH(NOLOCK) ON (F.IdFeeChecks = FC.IdFeeChecks ) WHERE IdAgent = @IdAgent)) --#1
			SET @MicrAmount = NULL

		Exec Corp.[st_SaveChangesToCheckLog_Checks] @IdCheck,60,'Duplicate Checks Validation on Update MICR', @EnteredByIdUser
		
		SET @FolioDuplicated  = (SELECT TOP 1 IdCheck FROM Checks WHERE CheckNumber = @CheckNumber AND RoutingNumber = @RoutingNumber AND MicrOnUs = @MicrOnUs AND Account = @Account AND IdStatus <> 31 AND IdCheck <> @IdCheck)

		IF (@FolioDuplicated IS NOT NULL)
		BEGIN
			SET @isDuplicate = 1;
			Exec Corp.[st_SaveChangesToCheckLog_Checks] @IdCheck,61,'Duplicated Check MICR on Update MIRC ', @EnteredByIdUser
		END					

		
		IF (@isDuplicate <= 0)
		BEGIN
			UPDATE Checks SET 
				MicrAuxOnUs =				@MicrAuxOnUs,
				RoutingNumber =				@RoutingNumber,
				MicrOnUs =					@MicrOnUs,
				Amount =					CONVERT(MONEY, ISNULL(@MicrAmount,Amount)),
				MicrAmount =				@MicrAmount,
				Account =					@Account,
				MicrManual =				@MicrManual,
				MicrRoutingTransitNumber =	@MicrRoutingTransitNumber,
				CheckNumber =				@CheckNumber
			WHERE IdCheck = @IdCheck
		END
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max)                                                                                             
		SELECT @ErrorMessage=ERROR_MESSAGE()                                             
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) 
		VALUES ('st_UpdateCheckMicr', GETDATE(),@ErrorMessage)                                                                                            
	END CATCH
END


