CREATE TABLE [dbo].[AgentCustomerMovementElasticError] (
    [IdAgentCustomerMovementElasticError] INT           IDENTITY (1, 1) NOT NULL,
    [IdAgentOrigin]                       INT           NULL,
    [IdAgentDestiny]                      INT           NULL,
    [IdElasticCustomers]                  VARCHAR (MAX) NULL,
    [EnterByIdUser]                       INT           NULL,
    [DateOfMovement]                      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdAgentCustomerMovementElasticError] ASC),
    CONSTRAINT [FK_AgentCustomerMovementElasticError_Agent] FOREIGN KEY ([IdAgentOrigin]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCustomerMovementElasticError2_Agent] FOREIGN KEY ([IdAgentDestiny]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_AgentCustomerMovementElasticError3_Agent] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

