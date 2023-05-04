CREATE PROCEDURE MoneyGram.st_SaveCountryCurrency
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
            t.c.value('BaseCurrency[1]', 'varchar(200)') BaseCurrency,
            t.c.value('LocalCurrency[1]', 'varchar(200)') LocalCurrency,
            t.c.value('ReceiveCurrency[1]', 'varchar(200)') ReceiveCurrency,
            t.c.value('IndicativeRateAvailable[1]', 'BIT') IndicativeRateAvailable,
            t.c.value('DeliveryOption[1]', 'varchar(200)') DeliveryOption,
            t.c.value('ReceiveAgentID[1]', 'varchar(200)') ReceiveAgentID,
            t.c.value('ReceiveAgentAbbreviation[1]', 'varchar(200)') ReceiveAgentAbbreviation,
            t.c.value('MgManaged[1]', 'varchar(200)') MgManaged,
            t.c.value('AgentManaged[1]', 'varchar(200)') AgentManaged
        FROM @XMLSource.nodes('root/CountryCurrencyCatalog') t(c)
    )
    MERGE MoneyGram.CountryCurrency AS t
    USING XMLCatalog c ON 
        t.CountryCode = c.CountryCode 
        AND t.BaseCurrency = c.BaseCurrency 
        AND t.LocalCurrency = c.LocalCurrency 
        AND t.ReceiveCurrency = c.ReceiveCurrency 
        AND t.IndicativeRateAvailable = c.IndicativeRateAvailable 
        AND t.DeliveryOption = c.DeliveryOption 
        AND t.ReceiveAgentID = c.ReceiveAgentID 
    WHEN MATCHED THEN
        UPDATE SET
            CountryCode = c.CountryCode,
            BaseCurrency = c.BaseCurrency,
            LocalCurrency = c.LocalCurrency,
            ReceiveCurrency = c.ReceiveCurrency,
            IndicativeRateAvailable = c.IndicativeRateAvailable,
            DeliveryOption = c.DeliveryOption,
            ReceiveAgentID = c.ReceiveAgentID,
            ReceiveAgentAbbreviation = c.ReceiveAgentAbbreviation,
            MgManaged = c.MgManaged,
            AgentManaged = c.AgentManaged,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            CountryCode,
            BaseCurrency,
            LocalCurrency,
            ReceiveCurrency,
            IndicativeRateAvailable,
            DeliveryOption,
            ReceiveAgentID,
            ReceiveAgentAbbreviation,
            MgManaged,
            AgentManaged,
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.CountryCode,
            c.BaseCurrency,
            c.LocalCurrency,
            c.ReceiveCurrency,
            c.IndicativeRateAvailable,
            c.DeliveryOption,
            c.ReceiveAgentID,
            c.ReceiveAgentAbbreviation,
            c.MgManaged,
            c.AgentManaged,
            NULL, 
            GETDATE()
        );
END