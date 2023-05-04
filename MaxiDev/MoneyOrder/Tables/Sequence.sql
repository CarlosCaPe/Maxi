CREATE TABLE [MoneyOrder].[Sequence] (
    [IdSequence]         INT      IDENTITY (1, 1) NOT NULL,
    [IdSequenceMovement] INT      NOT NULL,
    [Sequence]           BIGINT   NOT NULL,
    [IdSequenceStatus]   INT      NOT NULL,
    [CreationDate]       DATETIME NOT NULL,
    [DateOfLastChange]   DATETIME NOT NULL,
    [EnterByIdUser]      INT      NOT NULL,
    CONSTRAINT [PK_Sequence] PRIMARY KEY CLUSTERED ([IdSequence] ASC),
    CONSTRAINT [FK_Sequence_SequenceMovement] FOREIGN KEY ([IdSequenceMovement]) REFERENCES [MoneyOrder].[SequenceMovement] ([IdSequenceMovement]),
    CONSTRAINT [FK_Sequence_SequenceStatus] FOREIGN KEY ([IdSequenceStatus]) REFERENCES [MoneyOrder].[SequenceStatus] ([IdSequenceStatus]),
    CONSTRAINT [FK_Sequence_User_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

