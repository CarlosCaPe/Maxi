CREATE TABLE [dbo].[OtherChargesMemo] (
    [IdOtherChargesMemo] INT            IDENTITY (1, 1) NOT NULL,
    [Memo]               NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]   DATETIME       NOT NULL,
    [EnterByIdUser]      INT            NOT NULL,
    [IsValidReverse]     BIT            DEFAULT ((1)) NOT NULL,
    [IdQuickbook]        INT            NULL,
    [ForCredit]          BIT            NOT NULL,
    [ForDebit]           BIT            NOT NULL,
    [ReverseNote]        NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_OtherChargesMemo] PRIMARY KEY CLUSTERED ([IdOtherChargesMemo] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OtherChargesMemo_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

