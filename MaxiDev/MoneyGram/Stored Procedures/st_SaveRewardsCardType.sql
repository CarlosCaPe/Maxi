CREATE PROCEDURE MoneyGram.st_SaveRewardsCardType
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)
)
AS
BEGIN
    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('CardType[1]', 'varchar(200)') CardType,
            t.c.value('Description[1]', 'varchar(200)') [Description]
        FROM @XMLSource.nodes('root/RewardsCardTypeCatalog') t(c)
    )
    MERGE MoneyGram.RewardsCardType AS t
    USING XMLCatalog c ON 
        t.CardType = c.CardType 
        AND t.Description = c.Description
    WHEN MATCHED THEN
        UPDATE SET
            [CardType] = c.CardType,
            [Description] = c.Description,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            [CardType],
            [Description],
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.[CardType],
            c.[Description],
            NULL, 
            GETDATE()
        );
END