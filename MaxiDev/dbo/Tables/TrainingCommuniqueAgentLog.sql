CREATE TABLE [dbo].[TrainingCommuniqueAgentLog] (
    [IdTrainingCommuniqueAgentLog]    INT          IDENTITY (1, 1) NOT NULL,
    [IdTrainingCommuniqueAgentAnswer] INT          NOT NULL,
    [Action]                          VARCHAR (20) NOT NULL,
    [LogDate]                         DATETIME     NOT NULL,
    [IdUser]                          INT          NOT NULL,
    CONSTRAINT [PK_IdTrainingCommuniqueAgentLog] PRIMARY KEY CLUSTERED ([IdTrainingCommuniqueAgentLog] ASC),
    CONSTRAINT [CK_TrainingCommuniqueAgentLog_Action] CHECK ([Action]='Acknowledgement' OR [Action]='Restart' OR [Action]='View'),
    CONSTRAINT [FK_TrainingCommuniqueAgentLog_TrainingCommuniqueAgentAnswer] FOREIGN KEY ([IdTrainingCommuniqueAgentAnswer]) REFERENCES [dbo].[TrainingCommuniqueAgentAnswer] ([IdTrainingCommuniqueAgentAnswer]),
    CONSTRAINT [FK_TrainingCommuniqueAgentLog_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

