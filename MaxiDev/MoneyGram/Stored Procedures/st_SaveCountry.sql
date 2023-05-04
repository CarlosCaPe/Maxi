CREATE PROCEDURE MoneyGram.st_SaveCountry
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
            t.c.value('CountryName[1]', 'varchar(200)') CountryName,
            t.c.value('CountryLegacyCode[1]', 'varchar(200)') CountryLegacyCode,
            t.c.value('SendActive[1]', 'BIT') SendActive,
            t.c.value('ReceiveActive[1]', 'BIT') ReceiveActive,
            t.c.value('DirectedSendCountry[1]', 'BIT') DirectedSendCountry,
            t.c.value('MgDirectedSendCountry[1]', 'BIT') MgDirectedSendCountry,
            t.c.value('BaseReceiveCurrency[1]', 'varchar(200)') BaseReceiveCurrency,
            t.c.value('IsZipCodeRequired[1]', 'BIT') IsZipCodeRequired
        FROM @XMLSource.nodes('root/CountryCatalog') t(c)
    )
    MERGE MoneyGram.Country AS t
    USING XMLCatalog c ON t.CountryCode = c.CountryCode
    WHEN MATCHED THEN
        UPDATE SET 
            CountryCode = c.CountryCode,
            CountryName = c.CountryName,
            CountryLegacyCode = c.CountryLegacyCode,
            SendActive = c.SendActive,
            ReceiveActive = c.ReceiveActive,
            DirectedSendCountry = c.DirectedSendCountry,
            MgDirectedSendCountry = c.MgDirectedSendCountry,
            BaseReceiveCurrency = c.BaseReceiveCurrency,
            IsZipCodeRequired = c.IsZipCodeRequired,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            CountryCode, 
            CountryName, 
            CountryLegacyCode,
            SendActive, 
            ReceiveActive, 
            DirectedSendCountry, 
            MgDirectedSendCountry, 
            BaseReceiveCurrency, 
            IsZipCodeRequired, 
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.CountryCode,
            c.CountryName,
            c.CountryLegacyCode,
            c.SendActive,
            c.ReceiveActive,
            c.DirectedSendCountry,
            c.MgDirectedSendCountry,
            c.BaseReceiveCurrency,
            c.IsZipCodeRequired, 
            NULL, 
            GETDATE()
        );
END