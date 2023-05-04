CREATE TABLE [dbo].[BancoUnionGeneradorFileName] (
    [IdFile]              INT          IDENTITY (1, 1) NOT NULL,
    [FileName]            VARCHAR (50) NOT NULL,
    [DateOfFileGenerator] DATETIME     NOT NULL,
    CONSTRAINT [PK_BancoUnionGeneradorFileName] PRIMARY KEY CLUSTERED ([IdFile] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_BancoUnionGeneradorFileName_DateOfFileGenerator]
    ON [dbo].[BancoUnionGeneradorFileName]([DateOfFileGenerator] ASC);

