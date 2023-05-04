CREATE TABLE [DTOne].[Currency] (
    [IdCurrency]       INT          IDENTITY (1, 1) NOT NULL,
    [CurrencyName]     NVARCHAR (3) NOT NULL,
    [DateOfCreation]   DATETIME     NOT NULL,
    [DateOfLastChange] DATETIME     NOT NULL,
    [EnterByIdUser]    INT          NOT NULL,
    CONSTRAINT [PK_TransferDTOCurrency] PRIMARY KEY CLUSTERED ([IdCurrency] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_DTOCurrency_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

