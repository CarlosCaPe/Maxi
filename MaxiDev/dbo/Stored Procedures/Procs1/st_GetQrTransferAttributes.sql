CREATE PROCEDURE [dbo].[st_GetQrTransferAttributes]
(
@SourcePath as nvarchar(250) output, 
@DestinationPath as nvarchar(250) output,
@Prefix as nvarchar(250) output,
@PendingPath as nvarchar(250) output, 
@HistoryPath as nvarchar(250) output, 
@ImageExtension as nvarchar(50) output
)	
AS
BEGIN
	SET @SourcePath = dbo.GetGlobalAttributeByName('QRTransferSourcePath')
	SET @DestinationPath = dbo.GetGlobalAttributeByName('QRTransferDestinationPath')
	SET @PendingPath = dbo.GetGlobalAttributeByName('QRTransferPendingPath')
	SET @ImageExtension = dbo.GetGlobalAttributeByName('QRTransferImageExtension')
	SET @HistoryPath = dbo.GetGlobalAttributeByName('QRTransferHistoryPath')
	SET @Prefix = dbo.GetGlobalAttributeByName('QRTransferPrefix')
END

