CREATE TABLE [dbo].[TimeZone] (
    [IdTimeZone]        INT           IDENTITY (1, 1) NOT NULL,
    [TimeZone]          NVARCHAR (70) NOT NULL,
    [HoursForLocalTime] INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TimeZone] PRIMARY KEY CLUSTERED ([IdTimeZone] ASC)
);

