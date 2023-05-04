CREATE TABLE [dbo].[AgentCustomerMovement] (
    [IdAgentCustomerMovement] INT      IDENTITY (1, 1) NOT NULL,
    [IdAgentOrigin]           INT      NULL,
    [IdAgentDestiny]          INT      NULL,
    [EnterByIdUser]           INT      NULL,
    [DateOfMovement]          DATETIME NULL,
    PRIMARY KEY CLUSTERED ([IdAgentCustomerMovement] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentCustomerMovement_Agent] FOREIGN KEY ([IdAgentOrigin]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCustomerMovement2_Agent] FOREIGN KEY ([IdAgentDestiny]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCustomerMovement3_Agent] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

