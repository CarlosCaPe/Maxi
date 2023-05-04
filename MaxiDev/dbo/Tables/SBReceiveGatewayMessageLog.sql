CREATE TABLE [dbo].[SBReceiveGatewayMessageLog] (
    [IdSBGatewayMessageLog] INT              IDENTITY (1, 1) NOT NULL,
    [ConversationID]        UNIQUEIDENTIFIER NULL,
    [MessageXML]            XML              NULL,
    [DateOfLastChange]      DATETIME         DEFAULT (getdate()) NOT NULL
);

