CREATE TABLE [dbo].[ComplianceProducts] (
    [IdComplianceProduct] INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NOT NULL,
    [IdStatus]            INT            DEFAULT ((0)) NOT NULL,
    [NameEn]              NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ComplianceProducts] PRIMARY KEY CLUSTERED ([IdComplianceProduct] ASC) WITH (FILLFACTOR = 90)
);

