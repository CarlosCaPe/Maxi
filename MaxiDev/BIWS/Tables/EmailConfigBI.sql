CREATE TABLE [BIWS].[EmailConfigBI] (
    [IdEmailConfigBI]       INT           IDENTITY (1, 1) NOT NULL,
    [Host]                  VARCHAR (50)  NOT NULL,
    [Port]                  INT           NOT NULL,
    [EnableSSL]             BIT           NOT NULL,
    [UseDefaultCredentials] BIT           NOT NULL,
    [UserName]              VARCHAR (50)  NOT NULL,
    [Password]              VARCHAR (50)  NOT NULL,
    [Alias]                 VARCHAR (50)  NOT NULL,
    [IdGenericStatus]       INT           NOT NULL,
    [EmailReceiver]         VARCHAR (500) NULL,
    CONSTRAINT [PK_EmailConfigBI] PRIMARY KEY CLUSTERED ([IdEmailConfigBI] ASC)
);

