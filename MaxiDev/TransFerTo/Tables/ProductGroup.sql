CREATE TABLE [TransFerTo].[ProductGroup] (
    [IdProductGroup]   INT           IDENTITY (1, 1) NOT NULL,
    [IdCarrierTTo]     INT           NULL,
    [CodeGroup]        NVARCHAR (50) NOT NULL,
    [AliasProduct]     NCHAR (150)   NOT NULL,
    [DateOfLastChange] DATETIME      NOT NULL,
    [EnterByIdUser]    INT           NOT NULL,
    CONSTRAINT [PK_TransferTToProductGroup] PRIMARY KEY CLUSTERED ([IdProductGroup] ASC),
    CONSTRAINT [FK_TToProductGroup_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

