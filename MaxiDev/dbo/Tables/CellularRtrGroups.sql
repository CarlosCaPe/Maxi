CREATE TABLE [dbo].[CellularRtrGroups] (
    [IdCellularRtrGroup]        INT            IDENTITY (1, 1) NOT NULL,
    [Description]               NVARCHAR (MAX) NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX) NULL,
    [LastChange_LastDateChange] DATETIME       NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX) NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([IdCellularRtrGroup] ASC) WITH (FILLFACTOR = 90)
);

