CREATE TABLE [dbo].[ReasonNotCustomerCellphone] (
    [IdReasonNotCustomerCellphone] INT            IDENTITY (1, 1) NOT NULL,
    [Reason]                       NVARCHAR (250) NOT NULL,
    [IdGenericStatus]              INT            NULL,
    [CreationDate]                 DATETIME       DEFAULT (getdate()) NOT NULL,
    [DateOfLastChange]             DATETIME       DEFAULT (getdate()) NOT NULL,
    [EnterByIdUser]                INT            NULL,
    [ReasonEn]                     NVARCHAR (250) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdReasonNotCustomerCellphone] ASC),
    FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus])
);

