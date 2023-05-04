CREATE TABLE [dbo].[StatusToSendCellularMsg] (
    [IdStatusToSendCellularMsg] INT            IDENTITY (1, 1) NOT NULL,
    [IdStatus]                  INT            NOT NULL,
    [IdPaymentType]             INT            NOT NULL,
    [SubjectMessage]            NVARCHAR (MAX) NOT NULL,
    [BodyMessage]               NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]          DATETIME       NULL,
    [EnterByIdUser]             INT            NOT NULL,
    CONSTRAINT [PK_StatusToSendCellularMsg] PRIMARY KEY CLUSTERED ([IdStatusToSendCellularMsg] ASC)
);

