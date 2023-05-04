CREATE TABLE [FAX].[ErrorLogForStoreProcedures] (
    [IdLogFAX]       INT           IDENTITY (1, 1) NOT NULL,
    [StoreProcedure] VARCHAR (200) NOT NULL,
    [ErrorMessage]   VARCHAR (MAX) NOT NULL,
    [ErrorLine]      INT           NOT NULL,
    [Parameters]     VARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_InterFAXErrorLogForStoreProcedures] PRIMARY KEY CLUSTERED ([IdLogFAX] ASC)
);

