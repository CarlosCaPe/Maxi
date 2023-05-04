CREATE TABLE [dbo].[ServiceLogDetails] (
    [Id]                  INT              IDENTITY (1, 1) NOT NULL,
    [ServiceSummaryLogId] UNIQUEIDENTIFIER NOT NULL,
    [Message]             VARCHAR (MAX)    NOT NULL,
    [Category]            VARCHAR (20)     NOT NULL,
    [DateLog]             DATETIME         NOT NULL,
    CONSTRAINT [PK_ServiceLogDetails] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IDX_Category_DateLog_Includes]
    ON [dbo].[ServiceLogDetails]([Category] ASC, [DateLog] ASC);

