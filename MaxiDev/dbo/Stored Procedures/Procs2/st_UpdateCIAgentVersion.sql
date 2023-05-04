CREATE PROCEDURE st_UpdateCIAgentVersion
(
	@NewVersion	NVARCHAR(50)
)
AS
UPDATE GlobalAttributes SET
	Value = @NewVersion,
	Description = CONCAT('Last Update ', GETDATE())
WHERE Name = 'tmpCurrentVersionV2_0'