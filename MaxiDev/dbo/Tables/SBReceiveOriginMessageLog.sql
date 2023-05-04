CREATE TABLE [dbo].[SBReceiveOriginMessageLog] (
    [IdSBOriginMessageLog] INT              IDENTITY (1, 1) NOT NULL,
    [ConversationID]       UNIQUEIDENTIFIER NULL,
    [MessageXML]           XML              NULL,
    [DateOfLastChange]     DATETIME         DEFAULT (getdate()) NOT NULL,
    [IdTransfer]           INT              NULL
);

