-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-05-24
-- Description:	This stored save payment info from gateway
-- =============================================
CREATE PROCEDURE [dbo].[st_SavePayInfoTransferToMobile]
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
	DECLARE @DateOfPayment DATETIME

	SELECT
		@DateOfPayment = T.[xmlString].value('(/GatewayResponse//processingDateEnd/node())[1]', 'DATETIME')
	FROM (SELECT @XmlValue AS [xmlString]) T

	INSERT INTO [dbo].[TransferPayInfo] (IdTransfer,ClaimCode,IdGateway,DateOfPayment,BranchCode,BeneficiaryIdNumber,BeneficiaryIdType,IdBranch)
    VALUES (@IdTransfer,@ClaimCode,@IdGateway,@DateOfPayment,'','',0,NULL)

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_SavePayInfoTransferToMobile: @XmlValue: ' + CONVERT(varchar,@XmlValue),GETDATE(),@ErrorMessage)
END CATCH
