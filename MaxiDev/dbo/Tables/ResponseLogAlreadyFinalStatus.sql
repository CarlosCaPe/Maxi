CREATE TABLE [dbo].[ResponseLogAlreadyFinalStatus] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Fecha]          DATETIME       NULL,
    [IdGateway]      INT            NULL,
    [claimcode]      NVARCHAR (MAX) NULL,
    [ReturnCode]     NVARCHAR (MAX) NULL,
    [ReturnCodeType] INT            NULL,
    [XMLResponse]    XML            NULL
);

