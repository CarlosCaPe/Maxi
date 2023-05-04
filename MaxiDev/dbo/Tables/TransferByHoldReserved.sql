CREATE TABLE [dbo].[TransferByHoldReserved] (
    [idReserved]       INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]       INT            NOT NULL,
    [IdUser]           INT            NOT NULL,
    [Folio]            INT            NULL,
    [AgentCode]        NVARCHAR (20)  NOT NULL,
    [AgentName]        NVARCHAR (20)  NOT NULL,
    [DateOfReserved]   DATETIME       NOT NULL,
    [IdStatusReserved] INT            NOT NULL,
    [IdUploadFile]     INT            NOT NULL,
    [FilePath]         NVARCHAR (100) NULL,
    [IdStatus]         INT            NULL
);

