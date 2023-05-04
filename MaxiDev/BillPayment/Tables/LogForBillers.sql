CREATE TABLE [BillPayment].[LogForBillers] (
    [IdLogBiller]     INT           IDENTITY (1, 1) NOT NULL,
    [IdBiller]        INT           NOT NULL,
    [IdUser]          INT           NOT NULL,
    [MovementType]    VARCHAR (500) NULL,
    [DateLastChangue] DATETIME      NULL,
    [Description]     VARCHAR (500) NULL
);

