CREATE TABLE [dbo].[GenericStatus] (
    [IdGenericStatus] INT            IDENTITY (1, 1) NOT NULL,
    [GenericStatus]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_GenericStatus] PRIMARY KEY CLUSTERED ([IdGenericStatus] ASC) WITH (FILLFACTOR = 90)
);

