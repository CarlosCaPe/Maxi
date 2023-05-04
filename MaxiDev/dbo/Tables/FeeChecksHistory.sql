CREATE TABLE [dbo].[FeeChecksHistory] (
    [IdFeeChecksHistory] INT           IDENTITY (1, 1) NOT NULL,
    [IdFeeChecks]        INT           NOT NULL,
    [FeeType]            NVARCHAR (50) NOT NULL,
    [Fee]                MONEY         NOT NULL,
    [DateOfLastChange]   DATETIME      NOT NULL,
    [EnterByIdUser]      INT           NOT NULL,
    CONSTRAINT [PK_FeeChecksHistory] PRIMARY KEY CLUSTERED ([IdFeeChecksHistory] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_FeeChecksHistory_IdFeeChecks_FeeType]
    ON [dbo].[FeeChecksHistory]([IdFeeChecks] ASC, [FeeType] ASC);

