CREATE TABLE [dbo].[payercomm] (
    [payername]    VARCHAR (37)   NOT NULL,
    [currency]     VARCHAR (18)   NOT NULL,
    [cash]         NUMERIC (3, 2) NULL,
    [directedcash] NUMERIC (3, 2) NULL,
    [deposit]      NUMERIC (3, 2) NULL,
    [homedelivery] NUMERIC (3, 2) NULL,
    [idpayer]      INT            NULL
);

