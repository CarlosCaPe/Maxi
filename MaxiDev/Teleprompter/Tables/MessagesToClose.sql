CREATE TABLE [Teleprompter].[MessagesToClose] (
    [IdMessage]     INT           IDENTITY (1, 1) NOT NULL,
    [StateCode]     VARCHAR (10)  NULL,
    [MessageEn]     VARCHAR (MAX) NULL,
    [MessageEs]     VARCHAR (MAX) NULL,
    [EnterByIdUser] INT           NULL,
    [CreationDate]  DATETIME      CONSTRAINT [DF_Teleprompter_MessagesToClose_CreatedDate] DEFAULT (getdate()) NOT NULL
);

