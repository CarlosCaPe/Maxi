CREATE TABLE [dbo].[CC_AccVerifByAg] (
    [IdAccVerifByAg]  INT          IDENTITY (1, 1) NOT NULL,
    [DateCreated]     DATETIME     NULL,
    [Routing]         VARCHAR (50) NULL,
    [Account]         VARCHAR (50) NULL,
    [CheckNum]        VARCHAR (50) NULL,
    [IdCheck]         INT          NULL,
    [IdUser]          INT          NULL,
    [IdAgent]         INT          NULL,
    [IdLog]           INT          NULL,
    [IdIssuer]        INT          NULL,
    [Provider]        VARCHAR (50) NULL,
    [VerificationFee] MONEY        NULL,
    CONSTRAINT [PK_CC_AccVerifByAg] PRIMARY KEY CLUSTERED ([IdAccVerifByAg] ASC)
);

