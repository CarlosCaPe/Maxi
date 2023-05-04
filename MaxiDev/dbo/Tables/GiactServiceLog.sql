CREATE TABLE [dbo].[GiactServiceLog] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [UniqueId]     VARCHAR (36)  NULL,
    [DateRecord]   DATETIME      CONSTRAINT [DF__GiactServ__DateR__34D6DD33] DEFAULT (getdate()) NOT NULL,
    [StsError]     BIT           CONSTRAINT [DF__GiactServ__StsEr__35CB016C] DEFAULT ((0)) NOT NULL,
    [Error]        VARCHAR (MAX) NULL,
    [ResquestJSON] VARCHAR (MAX) NOT NULL,
    [ResponseJSON] VARCHAR (MAX) NULL,
    CONSTRAINT [PK_GiactServiceLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);

