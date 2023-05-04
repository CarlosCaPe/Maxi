CREATE TABLE [dbo].[Branch] (
    [IdBranch]         INT            IDENTITY (1, 1) NOT NULL,
    [IdPayer]          INT            NOT NULL,
    [BranchName]       NVARCHAR (MAX) NOT NULL,
    [IdCity]           INT            NOT NULL,
    [Address]          NVARCHAR (MAX) NOT NULL,
    [zipcode]          NVARCHAR (MAX) NOT NULL,
    [Phone]            NVARCHAR (MAX) NOT NULL,
    [Fax]              NVARCHAR (MAX) NOT NULL,
    [IdGenericStatus]  INT            NOT NULL,
    [DateOfLastChange] DATETIME       NOT NULL,
    [EnterByIdUser]    INT            NOT NULL,
    [code]             NVARCHAR (MAX) NULL,
    [Schedule]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED ([IdBranch] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Branch_City] FOREIGN KEY ([IdCity]) REFERENCES [dbo].[City] ([IdCity]),
    CONSTRAINT [FK_Branch_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer])
);


GO
CREATE NONCLUSTERED INDEX [Idx_BranchPayerCityId]
    ON [dbo].[Branch]([IdCity] ASC, [IdPayer] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdBranch]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Branch_IdGenericStatus]
    ON [dbo].[Branch]([IdGenericStatus] ASC)
    INCLUDE([IdPayer], [IdCity]);


GO
CREATE NONCLUSTERED INDEX [IX_Branch_IdPayer_IdCity_IdGenericStatus]
    ON [dbo].[Branch]([IdPayer] ASC, [IdCity] ASC, [IdGenericStatus] ASC)
    INCLUDE([IdBranch], [BranchName], [Address], [zipcode], [Phone], [Fax]);

