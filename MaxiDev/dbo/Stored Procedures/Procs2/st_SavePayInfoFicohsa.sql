CREATE PROCEDURE [dbo].[st_SavePayInfoFicohsa]
(
    @IdGateway		INT,
    @IdTransfer		INT,
    @Claimcode		NVARCHAR(max),    
    @XmlValue		XML
)
AS
BEGIN
	BEGIN TRY
		DECLARE @DateOfPayment	DATETIME,
				@Branch			NVARCHAR(50),
				@BenIdNumber	NVARCHAR(100),
				@BenIdType		NVARCHAR(100),
				@IdPayer		INT,
				@IdBranch		INT

		SELECT 
			@DateOfPayment = CONVERT(DATETIME, dbo.GetValueFromGatewayResponse(@XmlValue, 'FechaPago')),
			@Branch = dbo.GetValueFromGatewayResponse(@XmlValue, 'Location'),
			@BenIdNumber = dbo.GetValueFromGatewayResponse(@XmlValue, 'IdBeneficiario'),
			@BenIdType = dbo.GetValueFromGatewayResponse(@XmlValue, 'TipoId')

		SELECT TOP 1
			@IdPayer = T.IdPayer
		FROM Transfer t WITH(NOLOCK) 
		WHERE t.IdTransfer = @IdTransfer

		SET @IdBranch = dbo.funGetIdBranch(@Branch, @IdGateway, @IdPayer)

		INSERT INTO TransferPayInfo 
		(
			IdTransfer, 
			ClaimCode, 
			IdGateway, 
			DateOfPayment, 
			BranchCode, 
			BeneficiaryIdNumber, 
			BeneficiaryIdType, 
			IdBranch
		)
		VALUES
		(
			@IdTransfer,
			@Claimcode,
			@IdGateway,
			@DateOfPayment,
			@Branch,
			@BenIdNumber,
			@BenIdType,
			@IdBranch
		)

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(max)
		SET  @ErrorMessage = ERROR_MESSAGE()
		INSERT INTO ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage)
		Values('st_SavePayInfoFicohsa: @XmlValue: ' + CONVERT(VARCHAR,@XmlValue), GETDATE(), @ErrorMessage)
	END CATCH
END
