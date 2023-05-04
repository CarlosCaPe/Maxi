CREATE TABLE [dbo].[CellularRtrProducts] (
    [IdCellularProduct]         INT             IDENTITY (1, 1) NOT NULL,
    [Sku]                       INT             NOT NULL,
    [Description]               NVARCHAR (MAX)  NULL,
    [MinPrice]                  MONEY           NOT NULL,
    [MaxPrice]                  MONEY           NOT NULL,
    [Fee]                       DECIMAL (18, 2) NOT NULL,
    [IsFeePercentage]           BIT             NOT NULL,
    [IdCellularRtrGroup]        INT             NOT NULL,
    [IsEnabled]                 BIT             NOT NULL,
    [LastChange_LastUserChange] NVARCHAR (MAX)  NULL,
    [LastChange_LastDateChange] DATETIME        NOT NULL,
    [LastChange_LastIpChange]   NVARCHAR (MAX)  NULL,
    [LastChange_LastNoteChange] NVARCHAR (MAX)  NULL,
    PRIMARY KEY CLUSTERED ([IdCellularProduct] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [CellularRtrProduct_SelectedRtrGroup] FOREIGN KEY ([IdCellularRtrGroup]) REFERENCES [dbo].[CellularRtrGroups] ([IdCellularRtrGroup])
);

