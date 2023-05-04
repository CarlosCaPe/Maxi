CREATE TABLE [dbo].[FaxTrainingHistory] (
    [IdFaxTrainingHistory] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgent]              INT            NOT NULL,
    [IdUser]               INT            NOT NULL,
    [FileName]             NVARCHAR (MAX) NOT NULL,
    [Note]                 NVARCHAR (MAX) NULL,
    [Consecutive]          INT            NOT NULL,
    [DateOfCreation]       DATETIME       NULL,
    [DateOfApplication]    DATETIME       NULL,
    CONSTRAINT [PK_FaxTrainingHistory] PRIMARY KEY CLUSTERED ([IdFaxTrainingHistory] ASC)
);

