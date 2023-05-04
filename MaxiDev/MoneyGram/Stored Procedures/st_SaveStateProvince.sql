CREATE PROCEDURE MoneyGram.st_SaveStateProvince
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)
)
AS
BEGIN

    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('CountryCode[1]', 'varchar(200)') CountryCode,
            t.c.value('StateProvinceCode[1]', 'varchar(200)') StateProvinceCode,
            t.c.value('StateProvinceName[1]', 'varchar(200)') StateProvinceName
        FROM @XMLSource.nodes('root/StateProvinceCatalog') t(c)
    )
    MERGE MoneyGram.StateProvince AS t
    USING XMLCatalog c ON t.CountryCode = c.CountryCode AND t.StateProvinceCode = c.StateProvinceCode
    WHEN MATCHED THEN
        UPDATE SET 
            CountryCode = c.CountryCode,
            StateProvinceCode = c.StateProvinceCode,
            StateProvinceName = c.StateProvinceName,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            CountryCode,
            StateProvinceCode,
            StateProvinceName,
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.CountryCode,
            c.StateProvinceCode,
            c.StateProvinceName,
            NULL, 
            GETDATE()
        );
END