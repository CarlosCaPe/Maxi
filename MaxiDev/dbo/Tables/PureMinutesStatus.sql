CREATE TABLE [dbo].[PureMinutesStatus] (
    [IdPureMinutesStatus] INT            NOT NULL,
    [StatusName]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_PureMinutesStatus] PRIMARY KEY CLUSTERED ([IdPureMinutesStatus] ASC) WITH (FILLFACTOR = 90)
);

