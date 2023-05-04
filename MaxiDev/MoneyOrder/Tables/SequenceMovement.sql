CREATE TABLE [MoneyOrder].[SequenceMovement] (
    [IdSequenceMovement]     INT           IDENTITY (1, 1) NOT NULL,
    [IdAgent]                INT           NOT NULL,
    [InitialSequence]        BIGINT        NOT NULL,
    [FinalSequence]          BIGINT        NOT NULL,
    [IdSequenceMovementType] INT           NOT NULL,
    [Notes]                  VARCHAR (500) NULL,
    [CreationDate]           DATETIME      NOT NULL,
    [DateOfLastChange]       DATETIME      NOT NULL,
    [EnterByIdUser]          INT           NOT NULL,
    CONSTRAINT [PK_SequenceMovement] PRIMARY KEY CLUSTERED ([IdSequenceMovement] ASC),
    CONSTRAINT [FK_SequenceMovement_AgentRegistration_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_SequenceMovement_SequenceMovementType] FOREIGN KEY ([IdSequenceMovementType]) REFERENCES [MoneyOrder].[SequenceMovementType] ([IdSequenceMovementType]),
    CONSTRAINT [FK_SequenceMovement_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

