CREATE TABLE [dbo].[TransferFile] (
    [IdTransfer]       INT           NULL,
    [Agent]            INT           NULL,
    [IdCountryOrigin]  INT           NULL,
    [IdCountryDestiny] INT           NULL,
    [BeneficiaryState] VARCHAR (MAX) NULL,
    [FileName]         VARCHAR (MAX) NULL,
    [Url]              VARCHAR (MAX) NULL,
    [CreationDate]     DATETIME      DEFAULT (getdate()) NULL
);

