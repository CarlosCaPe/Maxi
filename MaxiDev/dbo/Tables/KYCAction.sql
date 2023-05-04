CREATE TABLE [dbo].[KYCAction] (
    [IdKYCAction] INT            NOT NULL,
    [Action]      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_KYCAction] PRIMARY KEY CLUSTERED ([IdKYCAction] ASC) WITH (FILLFACTOR = 90)
);

