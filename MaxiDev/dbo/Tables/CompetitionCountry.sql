CREATE TABLE [dbo].[CompetitionCountry] (
    [IdCompetitionCountry] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                 NVARCHAR (MAX) NULL,
    [DateOfLastChange]     DATETIME       NULL,
    [EnterByIdUser]        INT            NULL,
    [IdGenericStatus]      INT            NULL,
    CONSTRAINT [PK_CompetitionCountry] PRIMARY KEY CLUSTERED ([IdCompetitionCountry] ASC) WITH (FILLFACTOR = 90)
);

