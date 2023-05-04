CREATE TABLE [collection].[GroupsDetail] (
    [IdGroupsDetail] INT           IDENTITY (1, 1) NOT NULL,
    [IdGroups]       INT           NOT NULL,
    [Statecode]      NVARCHAR (20) NOT NULL,
    [IdSalesRep]     INT           NOT NULL,
    [AgentCode]      VARCHAR (25)  NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_GroupsDetail]
    ON [collection].[GroupsDetail]([IdGroupsDetail] ASC);


GO
CREATE NONCLUSTERED INDEX [GroupsDetailIdGroupsInclude]
    ON [collection].[GroupsDetail]([Statecode] ASC, [IdSalesRep] ASC)
    INCLUDE([IdGroups]);


GO
CREATE NONCLUSTERED INDEX [IX_GroupsDetail_IdGroups]
    ON [collection].[GroupsDetail]([IdGroups] ASC)
    INCLUDE([IdGroupsDetail], [Statecode], [IdSalesRep]);

