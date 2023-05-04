CREATE TABLE [Soporte].[TransferUpdateRequest] (
    [IdTransferUpdateRequest] BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdTransfer]              BIGINT        NOT NULL,
    [CreationDate]            DATETIME      CONSTRAINT [UQ_GatewayTransferUpdateRequest_CreationDate] DEFAULT (getdate()) NULL,
    [RequestSent]             BIT           NULL,
    [ReturnCode]              VARCHAR (200) NULL,
    [XMLResponse]             XML           NULL,
    [DateOfLastChange]        DATETIME      NULL,
    CONSTRAINT [PK_GatewayTransferUpdateRequest] PRIMARY KEY CLUSTERED ([IdTransferUpdateRequest] ASC)
);

