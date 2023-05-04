CREATE PROCEDURE FD_GetCustomFieldsMapping
(
	@IdFDEntity INT,
	@IdEnviroment INT
)
AS
BEGIN
	SELECT
		cm.Field,
		cm.Value
	FROM FD_CustomFieldsMapping cm
	WHERE cm.IdFDEntity = @IdFDEntity
		AND	cm.IdEnviroment = @IdEnviroment
END

