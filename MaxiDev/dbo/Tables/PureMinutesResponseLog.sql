CREATE TABLE [dbo].[PureMinutesResponseLog] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [IdPureMinutes] NVARCHAR (MAX) NULL,
    [date]          DATETIME       NULL,
    [Status]        INT            NOT NULL,
    [ReturnCode]    NVARCHAR (MAX) NULL,
    [Request]       NVARCHAR (MAX) NULL,
    [Response]      NVARCHAR (MAX) NULL
);

