CREATE TABLE [dbo].[GenericTableLog] (
    [IdGenericTableLog] BIGINT        IDENTITY (1, 1) NOT NULL,
    [ObjectName]        VARCHAR (MAX) NULL,
    [IdGeneric]         BIGINT        NULL,
    [Operation]         VARCHAR (50)  NULL,
    [XMLValues]         XML           NULL,
    [DateOfLastChange]  DATETIME      NULL,
    [EnterByIdUser]     INT           NULL,
    CONSTRAINT [PK_GenericTableLog] PRIMARY KEY CLUSTERED ([IdGenericTableLog] ASC)
);

