CREATE TABLE [dbo].[ComplianceFormat] (
    [ComplianceFormatId] INT            IDENTITY (1, 1) NOT NULL,
    [DisplayName]        NVARCHAR (MAX) NOT NULL,
    [FileOfName]         NVARCHAR (MAX) NOT NULL,
    PRIMARY KEY CLUSTERED ([ComplianceFormatId] ASC)
);

