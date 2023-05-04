CREATE TABLE [dbo].[CardType] (
    [IdCardType]       SMALLINT       IDENTITY (1, 1) NOT NULL,
    [Code]             NVARCHAR (50)  NOT NULL,
    [CardType]         NVARCHAR (100) NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    CONSTRAINT [PK_CardType] PRIMARY KEY CLUSTERED ([IdCardType] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [U_CardType_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);

