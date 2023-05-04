CREATE TABLE [moneyalert].[CorporateChat] (
    [IdCorporateChat] INT      IDENTITY (1, 1) NOT NULL,
    [IdUser]          INT      NOT NULL,
    [IdChat]          INT      NOT NULL,
    [EnteredDate]     DATETIME NOT NULL,
    CONSTRAINT [PK_CorporateChat] PRIMARY KEY CLUSTERED ([IdCorporateChat] ASC),
    CONSTRAINT [FK_CorporateChat_Chat] FOREIGN KEY ([IdChat]) REFERENCES [moneyalert].[Chat] ([IdChat])
);

