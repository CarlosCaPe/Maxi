CREATE TABLE [dbo].[RelationTimeZoneState] (
    [IdRelationTimeZoneState] INT IDENTITY (1, 1) NOT NULL,
    [IdTimeZone]              INT NOT NULL,
    [IdState]                 INT NOT NULL,
    CONSTRAINT [PK_RelationTimeZoneState] PRIMARY KEY CLUSTERED ([IdRelationTimeZoneState] ASC),
    CONSTRAINT [RelationTimeZoneState_State] FOREIGN KEY ([IdState]) REFERENCES [dbo].[State] ([IdState]),
    CONSTRAINT [RelationTimeZoneState_TimeZone] FOREIGN KEY ([IdTimeZone]) REFERENCES [dbo].[TimeZone] ([IdTimeZone])
);

