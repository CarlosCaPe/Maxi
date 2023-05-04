CREATE PROCEDURE MoneyGram.st_SaveDeliveryOption
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)
)
AS
BEGIN

    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('DeliveryOptionID[1]', 'INT') DeliveryOptionID,
            t.c.value('DeliveryOption[1]', 'varchar(200)') DeliveryOption,
            t.c.value('DeliveryOptionName[1]', 'varchar(200)') DeliveryOptionName,
            t.c.value('DssOption[1]', 'BIT') DssOption
        FROM @XMLSource.nodes('root/DeliveryOptionCatalog') t(c)
    )
    MERGE MoneyGram.DeliveryOption AS t
    USING XMLCatalog c ON 
        t.DeliveryOptionID = c.DeliveryOptionID
    WHEN MATCHED THEN
        UPDATE SET
            DeliveryOptionID = c.DeliveryOptionID,
            DeliveryOption = c.DeliveryOption,
            DeliveryOptionName = c.DeliveryOptionName,
            DssOption = c.DssOption,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            DeliveryOptionID,
            DeliveryOption,
            DeliveryOptionName,
            DssOption,
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.DeliveryOptionID,
            c.DeliveryOption,
            c.DeliveryOptionName,
            c.DssOption,
            NULL, 
            GETDATE()
        );
END