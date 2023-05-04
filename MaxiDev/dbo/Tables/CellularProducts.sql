CREATE TABLE [dbo].[CellularProducts] (
    [IdCellularProduct]         INT             IDENTITY (1, 1) NOT NULL,
    [IdCellularGroup]           INT             NOT NULL,
    [Sku]                       INT             NOT NULL,
    [Description]               NVARCHAR (MAX)  NULL,
    [Price]                     MONEY           NOT NULL,
    [Fee]                       DECIMAL (18, 2) NOT NULL,
    [IsFeePercentage]           BIT             NOT NULL,
    [IsEnabled]                 BIT             NOT NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX)  NULL,
    [LastChange_LastDateChange] DATETIME        NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX)  NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX)  NULL,
    PRIMARY KEY CLUSTERED ([IdCellularProduct] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [CellularProduct_SelectedGroup] FOREIGN KEY ([IdCellularGroup]) REFERENCES [dbo].[CellularGroups] ([IdCellularGroup])
);

