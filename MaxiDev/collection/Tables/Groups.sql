CREATE TABLE [collection].[Groups] (
    [IdGroups]         INT            IDENTITY (1, 1) NOT NULL,
    [groupName]        NVARCHAR (500) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    [IdUserAssign]     INT            NULL,
    [IsSpecial]        BIT            DEFAULT ((0)) NOT NULL,
    [IdAgentClass]     INT            NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_Groups]
    ON [collection].[Groups]([IdGroups] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Groups]
    ON [collection].[Groups]([groupName] ASC);

