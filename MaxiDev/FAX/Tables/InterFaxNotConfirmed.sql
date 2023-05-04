CREATE TABLE [FAX].[InterFaxNotConfirmed] (
    [IdFax]          INT            IDENTITY (1, 1) NOT NULL,
    [IdInterfax]     INT            NOT NULL,
    [Path]           NVARCHAR (MAX) NOT NULL,
    [Status]         INT            NOT NULL,
    [CreationDate]   DATETIME       NOT NULL,
    [LastChangeDate] DATETIME       NOT NULL,
    [IsDel]          BIT            NOT NULL
);

