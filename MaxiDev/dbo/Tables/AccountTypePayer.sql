CREATE TABLE [dbo].[AccountTypePayer] (
    [AccountTypePayerId] INT          IDENTITY (1, 1) NOT NULL,
    [IdPayer]            INT          NOT NULL,
    [AccountTypeId]      INT          NOT NULL,
    [AccountTypeName]    VARCHAR (50) NOT NULL,
    [idLenguage]         INT          NOT NULL,
    CONSTRAINT [PK_AccountTypePayer] PRIMARY KEY CLUSTERED ([AccountTypePayerId] ASC)
);

