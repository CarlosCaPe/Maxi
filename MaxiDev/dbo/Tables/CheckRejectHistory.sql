CREATE TABLE [dbo].[CheckRejectHistory] (
    [IdCheckRejectHistory] INT           IDENTITY (1, 1) NOT NULL,
    [IdCheck]              INT           NOT NULL,
    [RoutingNumber]        VARCHAR (MAX) NOT NULL,
    [AccountNumber]        VARCHAR (MAX) NOT NULL,
    [IdReturnedReason]     INT           NOT NULL,
    [DateOfReject]         DATETIME      NOT NULL,
    [EnterByIdUser]        INT           NOT NULL,
    [CreationDate]         DATETIME      NOT NULL,
    [DateofLastChange]     DATETIME      NOT NULL,
    [IrdPrinted]           BIT           NULL,
    [IrdMicr]              VARCHAR (100) NULL,
    CONSTRAINT [PK_CheckRejectHistory] PRIMARY KEY CLUSTERED ([IdCheckRejectHistory] ASC)
);

