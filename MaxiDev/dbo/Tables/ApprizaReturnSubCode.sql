CREATE TABLE [dbo].[ApprizaReturnSubCode] (
    [IdApprizaReturnSubCode] INT           IDENTITY (1, 1) NOT NULL,
    [IdGatewayReturnCode]    INT           NULL,
    [ReturnSubCode]          NVARCHAR (16) NULL,
    [IdDocument]             INT           NULL,
    CONSTRAINT [PK_IdApprizaRetSubCode] PRIMARY KEY CLUSTERED ([IdApprizaReturnSubCode] ASC)
);

