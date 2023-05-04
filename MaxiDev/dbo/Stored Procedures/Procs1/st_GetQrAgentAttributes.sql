
create PROCEDURE [dbo].[st_GetQrAgentAttributes]
(
@SourcePath as nvarchar(250) output, 
@DestinationPath as nvarchar(250) output,
@Prefix as nvarchar(1) output,
@PendingPath as nvarchar(250) output, 
@HistoryPath as nvarchar(250) output, 
@ImageExtension as nvarchar(50) output
)	
AS
BEGIN
	SET @SourcePath = dbo.GetGlobalAttributeByName('QRAgentSourcePath')
	SET @DestinationPath = dbo.GetGlobalAttributeByName('QRAgentDestinationPath')
	SET @PendingPath = dbo.GetGlobalAttributeByName('QRAgentPendingPath')
	SET @ImageExtension = dbo.GetGlobalAttributeByName('QRAgentImageExtension')
	SET @HistoryPath = dbo.GetGlobalAttributeByName('QRAgentHistoryPath')
	SET @Prefix = dbo.GetGlobalAttributeByName('QRAgentPrefix')
END

