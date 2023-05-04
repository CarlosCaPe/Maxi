CREATE PROCEDURE MoneyGram.st_GetRequirements
AS
BEGIN
	SELECT
		CAST(dbo.GetGlobalAttributeByName('MoneyGram_IdGateway') AS INT) IdGateway
END