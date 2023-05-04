CREATE TABLE [Regalii].[UpdateLog] (
    [IdUpdateLog]  INT           IDENTITY (1, 1) NOT NULL,
    [Type]         VARCHAR (50)  NOT NULL,
    [CreationDate] DATETIME      NOT NULL,
    [Detail]       VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_UpdateLog] PRIMARY KEY CLUSTERED ([IdUpdateLog] ASC)
);

