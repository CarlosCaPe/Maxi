CREATE TABLE [dbo].[CBLAction] (
    [IdCBLAction] INT            NOT NULL,
    [Action]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_CBLAction] PRIMARY KEY CLUSTERED ([IdCBLAction] ASC) WITH (FILLFACTOR = 90)
);

