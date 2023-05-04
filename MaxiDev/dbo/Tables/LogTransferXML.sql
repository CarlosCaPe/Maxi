CREATE TABLE [dbo].[LogTransferXML] (
    [IdLog]       INT           IDENTITY (1, 1) NOT NULL,
    [CreateDate]  DATETIME      CONSTRAINT [DF_LogTransferXML_CreateDate] DEFAULT (getdate()) NOT NULL,
    [ContentData] VARCHAR (MAX) NULL,
    [IdCustomer]  INT           NULL,
    CONSTRAINT [PK_LogTransferXML] PRIMARY KEY CLUSTERED ([IdLog] ASC)
);

