CREATE TABLE [dbo].[FD_InquiryTicket] (
    [Id]                  INT           NOT NULL,
    [IdTransfer]          INT           NOT NULL,
    [SendInquiryLetter]   BIT           NOT NULL,
    [IdFileInquiryLetter] INT           NULL,
    [CustomerEmail]       VARCHAR (30)  NULL,
    [InquiryReason]       VARCHAR (500) NULL,
    [ErrorResolution]     BIT           NULL,
    [IdFileResolution]    INT           NULL,
    [EnterByIdUser]       INT           NOT NULL,
    [ResolutionDate]      DATETIME      NULL,
    [CreateDate]          DATETIME      NOT NULL,
    [ChangeByUser]        INT           NULL,
    [DateOfLastChange]    DATETIME      NULL,
    [InquiryReasonENG]    VARCHAR (500) NULL,
    CONSTRAINT [PK_FreshdeskTransferTicket] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_FDInquiryTicket_ChangeByUser] FOREIGN KEY ([ChangeByUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_FDInquiryTicket_EnterByIdUser] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_FDInquiryTicket_IdFileInquiryLetter] FOREIGN KEY ([IdFileInquiryLetter]) REFERENCES [dbo].[UploadFiles] ([IdUploadFile]),
    CONSTRAINT [FK_FDInquiryTicket_IdFileResolution] FOREIGN KEY ([IdFileResolution]) REFERENCES [dbo].[UploadFiles] ([IdUploadFile])
);

