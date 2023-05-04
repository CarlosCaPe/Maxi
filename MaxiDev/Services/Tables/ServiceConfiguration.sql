CREATE TABLE [Services].[ServiceConfiguration] (
    [Code]        NVARCHAR (128) NOT NULL,
    [Description] NVARCHAR (MAX) NULL,
    [LastTick]    DATETIME       NULL,
    [NextTick]    DATETIME       NULL,
    [IsEnabled]   BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90)
);

