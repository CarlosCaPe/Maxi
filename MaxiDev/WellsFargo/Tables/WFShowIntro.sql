CREATE TABLE [WellsFargo].[WFShowIntro] (
    [IdWFShowIntro]    INT      IDENTITY (1, 1) NOT NULL,
    [IdAgent]          INT      NOT NULL,
    [IsShow]           BIT      NOT NULL,
    [EnterByIdUser]    INT      NOT NULL,
    [CreationDate]     DATETIME NOT NULL,
    [DateOfLastChange] DATETIME NOT NULL,
    CONSTRAINT [PK_WFShowIntro] PRIMARY KEY CLUSTERED ([IdWFShowIntro] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_WFShowIntro_Agent] FOREIGN KEY ([IdAgent]) REFERENCES [dbo].[Agent] ([IdAgent]),
    CONSTRAINT [FK_WFShowIntro_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

