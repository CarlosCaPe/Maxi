CREATE TABLE [Services].[ServiceAttributes] (
    [Code]  NVARCHAR (128) NOT NULL,
    [Key]   NVARCHAR (128) NOT NULL,
    [Value] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Code] ASC, [Key] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [ServiceConfiguration_Attributes] FOREIGN KEY ([Code]) REFERENCES [Services].[ServiceConfiguration] ([Code])
);

