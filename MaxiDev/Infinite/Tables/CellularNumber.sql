CREATE TABLE [Infinite].[CellularNumber] (
    [IdCellularNumber]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [AllowSentMessages] BIT           DEFAULT ((1)) NOT NULL,
    [CreationDate]      DATETIME      NOT NULL,
    [LastChangeDate]    DATETIME      NOT NULL,
    [NumberWithFormat]  NVARCHAR (14) NOT NULL,
    [IsCustomer]        BIT           DEFAULT ((0)) NOT NULL,
    [InterCode]         NVARCHAR (10) DEFAULT ('1') NOT NULL,
    [IdCustomer]        INT           NULL,
    PRIMARY KEY CLUSTERED ([IdCellularNumber] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idxNumWithFormAllowMsg]
    ON [Infinite].[CellularNumber]([NumberWithFormat] ASC, [AllowSentMessages] ASC, [InterCode] ASC) WHERE ([IsCustomer]=(1)) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_CellularNumber_IsCustomer_InterCode]
    ON [Infinite].[CellularNumber]([IsCustomer] ASC, [InterCode] ASC)
    INCLUDE([AllowSentMessages], [NumberWithFormat]);

