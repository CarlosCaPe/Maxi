CREATE PROCEDURE MoneyGram.st_SaveCurrency
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)

)
AS
BEGIN

    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('CurrencyCode[1]', 'varchar(200)') CurrencyCode,
            t.c.value('CurrencyName[1]', 'varchar(200)') CurrencyName,
            t.c.value('CurrencyPrecision[1]', 'INT') CurrencyPrecision
        FROM @XMLSource.nodes('root/CurrencyCatalog') t(c)
    )
    MERGE MoneyGram.Currency AS t
    USING XMLCatalog c ON t.CurrencyCode = c.CurrencyCode
    WHEN MATCHED THEN
        UPDATE SET 
            CurrencyCode = c.CurrencyCode,
            CurrencyName = c.CurrencyName,
            CurrencyPrecision = c.CurrencyPrecision,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (CurrencyCode, CurrencyName, CurrencyPrecision, DateOfLastChange, CreationDate)
        VALUES (c.CurrencyCode, c.CurrencyName, c.CurrencyPrecision, NULL, GETDATE());
END