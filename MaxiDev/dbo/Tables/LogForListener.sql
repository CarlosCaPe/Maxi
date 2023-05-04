CREATE TABLE [dbo].[LogForListener] (
    [IdLog]            INT            IDENTITY (1, 1) NOT NULL,
    [Type]             VARCHAR (50)   NOT NULL,
    [Proyect]          VARCHAR (100)  NOT NULL,
    [SessionGuid]      VARCHAR (50)   NULL,
    [IdUser]           INT            NULL,
    [ClientDatetime]   DATETIME       NOT NULL,
    [ServerDatetime]   DATETIME       CONSTRAINT [DF_LogForListener_ServerDatetime] DEFAULT (getdate()) NOT NULL,
    [Message]          NVARCHAR (MAX) NOT NULL,
    [StackTrace]       NVARCHAR (MAX) NULL,
    [Priority]         INT            NULL,
    [ExceptionMessage] NVARCHAR (MAX) NULL,
    [ExceptionSource]  NVARCHAR (MAX) NULL,
    [MethodsParams]    NVARCHAR (MAX) NULL,
    [IpNumber]         VARCHAR (50)   NULL,
    CONSTRAINT [PK_ErrorLogForListener] PRIMARY KEY CLUSTERED ([IdLog] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX1_LogForListener]
    ON [dbo].[LogForListener]([ServerDatetime] ASC);

