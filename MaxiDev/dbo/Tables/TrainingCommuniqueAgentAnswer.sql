CREATE TABLE [dbo].[TrainingCommuniqueAgentAnswer] (
    [IdTrainingCommuniqueAgentAnswer] INT      IDENTITY (1, 1) NOT NULL,
    [IdTrainingCommunique]            INT      NOT NULL,
    [IdAgent]                         INT      NOT NULL,
    [Acknowledgement]                 BIT      NOT NULL,
    [ReviewDate]                      DATETIME NULL,
    [IdUserReviewed]                  INT      NULL,
    [CreationDate]                    DATETIME NOT NULL,
    [IdUser]                          INT      NOT NULL,
    CONSTRAINT [PK_TrainingCommuniqueAgentAnswer] PRIMARY KEY CLUSTERED ([IdTrainingCommuniqueAgentAnswer] ASC),
    CONSTRAINT [FK_TrainingCommuniqueAgentAnswer_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_TrainingCommuniqueAgentAnswer_TrainingCommunique] FOREIGN KEY ([IdTrainingCommunique]) REFERENCES [dbo].[TrainingCommunique] ([IdTrainingCommunique]),
    CONSTRAINT [FK_TrainingCommuniqueAgentAnswer_User_IdUser] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_TrainingCommuniqueAgentAnswer_User_IdUserReviewed] FOREIGN KEY ([IdUserReviewed]) REFERENCES [dbo].[Users] ([IdUser])
);

