CREATE TABLE [dbo].[SBMessageLog] (
    [IdSBOriginMessageLog] INT      IDENTITY (1, 1) NOT NULL,
    [IdTransfer]           INT      NULL,
    [MessageXML]           XML      NULL,
    [DateOfLastChange]     DATETIME DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_SBMessageLog] PRIMARY KEY CLUSTERED ([IdSBOriginMessageLog] ASC)
);

