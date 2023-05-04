CREATE TABLE [dbo].[ValidTransferStatusTransition] (
    [IdValidTransferStatusTransition] INT IDENTITY (1, 1) NOT NULL,
    [FromIdStatus]                    INT NULL,
    [ToIdStatus]                      INT NULL,
    CONSTRAINT [PK_ValidTransferStatusTransition] PRIMARY KEY CLUSTERED ([IdValidTransferStatusTransition] ASC)
);

