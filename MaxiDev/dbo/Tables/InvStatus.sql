CREATE TABLE [dbo].[InvStatus] (
    [IdInvStatus] INT            IDENTITY (1, 1) NOT NULL,
    [InvStatus]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_InvStatus] PRIMARY KEY CLUSTERED ([IdInvStatus] ASC) WITH (FILLFACTOR = 90)
);

