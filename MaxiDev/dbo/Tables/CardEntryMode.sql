CREATE TABLE [dbo].[CardEntryMode] (
    [IdCardEntryMode]  SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (50)  NOT NULL,
    [CardEntryMode]    NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_CardEntryMode] PRIMARY KEY CLUSTERED ([IdCardEntryMode] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [U_CardEntryMode_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);

