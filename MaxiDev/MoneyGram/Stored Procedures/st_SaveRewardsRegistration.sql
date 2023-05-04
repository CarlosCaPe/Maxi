CREATE PROCEDURE MoneyGram.st_SaveRewardsRegistration
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)
)
AS
BEGIN

    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('Country[1]', 'varchar(200)') Country,
            t.c.value('ProgramType[1]', 'varchar(200)') ProgramType,
            t.c.value('CardType[1]', 'varchar(200)') CardType,
            t.c.value('AllowPrePrintedCards[1]', 'BIT') AllowPrePrintedCards,
            t.c.value('AllowStandardCards[1]', 'BIT') AllowStandardCards
        FROM @XMLSource.nodes('root/RewardsRegistrationCatalog') t(c)
    )
    MERGE MoneyGram.RewardsRegistration AS t
    USING XMLCatalog c ON t.Country = c.Country AND t.ProgramType = c.ProgramType AND t.CardType = c.CardType
    WHEN MATCHED THEN
        UPDATE SET
            Country = c.Country,
            ProgramType = c.ProgramType,
            CardType = c.CardType,
            AllowPrePrintedCards = c.AllowPrePrintedCards,
            AllowStandardCards = c.AllowStandardCards,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            Country,
            ProgramType,
            CardType,
            AllowPrePrintedCards,
            AllowStandardCards,
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.Country,
            c.ProgramType,
            c.CardType,
            c.AllowPrePrintedCards,
            c.AllowStandardCards,
            NULL, 
            GETDATE()
        );
END