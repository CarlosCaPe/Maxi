CREATE PROCEDURE [dbo].[st_SavePayInfoGirosMex]
	-- Add the parameters for the stored procedure here
	@IdGateway  int,
    @idTransfer int,
    @Claimcode  nvarchar(max),    
    @XmlValue xml
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @dateofpayment DATETIME
    DECLARE @BenIdNumber NVARCHAR(MAX)
    DECLARE @BenIdType NVARCHAR(MAX)

	SELECT
		@BenIdType = ISNULL(T.[xmlString].value('(/NOTIFICACION_O//CVE_IDENTIFICACION/node())[1]', 'NVARCHAR(MAX)'),'NULL')
		,@BenIdNumber = ISNULL(T.[xmlString].value('(/NOTIFICACION_O//IdentificationNumber/node())[1]', 'NVARCHAR(MAX)'),'NULL')
		,@dateofpayment = CONVERT(DATETIME,T.[xmlString].value('(/NOTIFICACION_O//FECHA_PAGO/node())[1]', 'NVARCHAR(MAX)'))
	FROM (SELECT @XmlValue AS [xmlString]) T

	DECLARE @BranchCode NVARCHAR(MAX) = ''
	DECLARE @IdBranch int

	INSERT INTO [dbo].[TransferPayInfo] 
        (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    values
        (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,@BranchCode,@BenIdNumber,@BenIdType,@IdBranch)

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_SavePayInfoGirosMex: @XmlValue: ' + CONVERT(varchar,@XmlValue),GETDATE(),@ErrorMessage)
END CATCH
