CREATE TABLE [MoneyOrder].[SequenceDetail] (
    [IdSequenceDetail] INT      IDENTITY (1, 1) NOT NULL,
    [IdSequence]       INT      NOT NULL,
    [IdSequenceStatus] INT      NOT NULL,
    [CreationDate]     DATETIME NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    CONSTRAINT [PK_SequenceDetail] PRIMARY KEY CLUSTERED ([IdSequenceDetail] ASC),
    CONSTRAINT [FK_SequenceDetail_Sequence] FOREIGN KEY ([IdSequence]) REFERENCES [MoneyOrder].[Sequence] ([IdSequence]),
    CONSTRAINT [FK_SequenceDetail_SequenceStatus] FOREIGN KEY ([IdSequenceStatus]) REFERENCES [MoneyOrder].[SequenceStatus] ([IdSequenceStatus]),
    CONSTRAINT [FK_SequenceDetail_User_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

