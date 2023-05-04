CREATE PROCEDURE MoneyGram.st_SaveEnumerators
(
	@IdEnumeratedType				INT,
    @XMLSource						XML,
	@IdEnumeratorCatalogGFFPConfigs	INT,
    @AgentId						VARCHAR(200)
)
AS
BEGIN

	DECLARE @NewRecords TABLE (IdRecord INT)

    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('Label[1]', 'varchar(200)') [Label],
            t.c.value('Value[1]', 'varchar(200)') [Value]
        FROM @XMLSource.nodes('root/Enumerator') t(c)
    )
    MERGE MoneyGram.Enumerators AS t
    USING XMLCatalog c ON t.IdEnumeratedType = @IdEnumeratedType AND t.Value = c.Value
    WHEN MATCHED THEN
        UPDATE SET 
            Label = c.Label,
			DateOfLastChange = GETDATE(),
			Active = 1
    WHEN NOT MATCHED THEN
        INSERT (IdEnumeratedType, [Label], [Value], DateOfLastChange, CreationDate, Active)
		VALUES (@IdEnumeratedType, c.Label, c.Value, NULL, GETDATE(), 1)
	OUTPUT INSERTED.IdEnumerator INTO @NewRecords(IdRecord);

	UPDATE MoneyGram.Enumerators SET
		Active = 0,
		DateOfLastChange = GETDATE()
	WHERE IdEnumeratedType = @IdEnumeratedType
	AND NOT EXISTS (SELECT 1 FROM @NewRecords WHERE IdRecord = IdEnumerator)
END