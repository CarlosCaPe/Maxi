CREATE TABLE [dbo].[UsersSessionLog] (
    [IdUserSessionLog]   INT              IDENTITY (1, 1) NOT NULL,
    [SessionGuid]        UNIQUEIDENTIFIER NOT NULL,
    [IdUser]             INT              NOT NULL,
    [IP]                 VARCHAR (50)     NOT NULL,
    [DateOfCreation]     DATETIME         NOT NULL,
    [MachineDescription] NVARCHAR (MAX)   NOT NULL,
    CONSTRAINT [PK_UsersSessionLog] PRIMARY KEY CLUSTERED ([IdUserSessionLog] ASC)
);

