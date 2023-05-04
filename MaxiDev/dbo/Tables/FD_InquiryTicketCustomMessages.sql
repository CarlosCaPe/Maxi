CREATE TABLE [dbo].[FD_InquiryTicketCustomMessages] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [MessageESP]  VARCHAR (100) NOT NULL,
    [MessageENG]  VARCHAR (100) NOT NULL,
    [IsSecondary] BIT           NOT NULL,
    [CreateDate]  DATETIME      NOT NULL,
    CONSTRAINT [PK_InquiryTicketCustomMessages] PRIMARY KEY CLUSTERED ([Id] ASC)
);

