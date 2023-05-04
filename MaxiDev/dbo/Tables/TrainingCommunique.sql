CREATE TABLE [dbo].[TrainingCommunique] (
    [IdTrainingCommunique] INT           IDENTITY (1, 1) NOT NULL,
    [StartDate]            DATETIME      NOT NULL,
    [EndingDate]           DATETIME      NOT NULL,
    [Title]                VARCHAR (200) NOT NULL,
    [Description]          VARCHAR (200) NOT NULL,
    [IdStatus]             INT           NOT NULL,
    [Active]               AS            (case when [IdStatus]=(1) AND (getdate()>=[StartDate] AND getdate()<=[EndingDate]) then (1) else (0) end),
    [CreationDate]         DATETIME      NOT NULL,
    [IdUser]               INT           NOT NULL,
    CONSTRAINT [PK_TrainingCommunique] PRIMARY KEY CLUSTERED ([IdTrainingCommunique] ASC),
    CONSTRAINT [FK_TrainingCommunique_GenericStatus] FOREIGN KEY ([IdStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_TrainingCommunique_User] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

