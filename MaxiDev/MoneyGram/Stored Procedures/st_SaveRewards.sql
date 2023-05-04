CREATE PROCEDURE MoneyGram.st_SaveRewards
(
    @XMLSource  XML,
    @AgentId    VARCHAR(200)
)
AS
BEGIN
    ;WITH XMLCatalog AS
    (
        SELECT
            t.c.value('ProgramType[1]', 'varchar(200)') ProgramType,
            t.c.value('Name[1]', 'varchar(200)') [Name],
            t.c.value('Description[1]', 'varchar(200)') [Description]
        FROM @XMLSource.nodes('root/RewardsCatalog') t(c)
    )
    MERGE MoneyGram.Rewards AS t
    USING XMLCatalog c ON 
        t.ProgramType = c.ProgramType 
        AND t.Name = c.Name
    WHEN MATCHED THEN
        UPDATE SET
            [ProgramType] = c.ProgramType,
            [Name] = c.Name,
            [Description] = c.Description,
            DateOfLastChange = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT (
            [ProgramType],
            [Name],
            [Description],
            DateOfLastChange, 
            CreationDate
        )
        VALUES (
            c.[ProgramType],
            c.[Name],
            c.[Description],
            NULL, 
            GETDATE()
        );
END