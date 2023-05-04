CREATE TABLE [dbo].[WellsFargoLogFile] (
    [IdWellsFargo]       INT            IDENTITY (1, 1) NOT NULL,
    [IdTransfer]         INT            NOT NULL,
    [IdFileName]         INT            NOT NULL,
    [DateOfFileCreation] DATETIME       NOT NULL,
    [TypeOfTransfer]     NVARCHAR (MAX) NOT NULL
);

