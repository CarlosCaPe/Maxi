CREATE TABLE [dbo].[Carriers] (
    [IdCarrier] INT            NOT NULL,
    [Name]      VARCHAR (50)   NOT NULL,
    [Email]     NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_Carriers] PRIMARY KEY CLUSTERED ([IdCarrier] ASC) WITH (FILLFACTOR = 90)
);

