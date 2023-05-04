CREATE TABLE [dbo].[Spread] (
    [IdSpread]          INT            IDENTITY (1, 1) NOT NULL,
    [SpreadName]        NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]  DATETIME       NOT NULL,
    [EnterByIdUser]     INT            NOT NULL,
    [IdCountryCurrency] INT            NOT NULL,
    CONSTRAINT [PK_Spread] PRIMARY KEY CLUSTERED ([IdSpread] ASC)
);

