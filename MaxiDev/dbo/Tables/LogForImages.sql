CREATE TABLE [dbo].[LogForImages] (
    [IdLogImages]      INT              IDENTITY (1, 1) NOT NULL,
    [Process]          VARCHAR (50)     NULL,
    [Proyect]          VARCHAR (150)    NULL,
    [LogType]          VARCHAR (150)    NULL,
    [IdUser]           INT              NULL,
    [SessionGuid]      UNIQUEIDENTIFIER NULL,
    [IdAgent]          INT              NULL,
    [IdCheck]          INT              NULL,
    [CheckNumber]      VARCHAR (150)    NULL,
    [Note]             VARCHAR (MAX)    NULL,
    [ClientDateTime]   DATETIME         NULL,
    [ServerDateTime]   DATETIME         NULL,
    [ExceptionMessage] VARCHAR (MAX)    NULL,
    [StackTrace]       VARCHAR (MAX)    NULL,
    PRIMARY KEY CLUSTERED ([IdLogImages] ASC)
);

