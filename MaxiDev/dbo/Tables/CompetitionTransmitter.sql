CREATE TABLE [dbo].[CompetitionTransmitter] (
    [IdCompetitionTransmitter] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                     NVARCHAR (MAX) NULL,
    [DateOfLastChange]         DATETIME       NULL,
    [EnterByIdUser]            INT            NULL,
    [IdGenericStatus]          INT            NULL,
    CONSTRAINT [PK_CompetitionTransmitter] PRIMARY KEY CLUSTERED ([IdCompetitionTransmitter] ASC) WITH (FILLFACTOR = 90)
);

