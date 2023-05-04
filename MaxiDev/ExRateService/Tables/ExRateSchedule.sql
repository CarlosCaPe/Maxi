CREATE TABLE [ExRateService].[ExRateSchedule] (
    [IdExRateSchedule]  INT      IDENTITY (1, 1) NOT NULL,
    [IdCountryCurrency] INT      NOT NULL,
    [IdGateway]         INT      NULL,
    [IdPayer]           INT      NULL,
    [ExRate]            MONEY    NOT NULL,
    [ScheduleDate]      DATETIME NOT NULL,
    [EnterByIdUser]     INT      NOT NULL,
    [DateOfLastChange]  DATETIME NOT NULL,
    [ServiceApplyDate]  DATETIME NULL,
    [IsApply]           BIT      DEFAULT ((0)) NOT NULL,
    [IdGenericStatus]   INT      NOT NULL,
    CONSTRAINT [PK_ExRateSchedule] PRIMARY KEY CLUSTERED ([IdExRateSchedule] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ExRateSchedule_CountryCurrency] FOREIGN KEY ([IdCountryCurrency]) REFERENCES [dbo].[CountryCurrency] ([IdCountryCurrency]),
    CONSTRAINT [FK_ExRateSchedule_Gateway] FOREIGN KEY ([IdGateway]) REFERENCES [dbo].[Gateway] ([IdGateway]),
    CONSTRAINT [FK_ExRateSchedule_GenericStatus] FOREIGN KEY ([IdGenericStatus]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [FK_ExRateSchedule_Payer] FOREIGN KEY ([IdPayer]) REFERENCES [dbo].[Payer] ([IdPayer]),
    CONSTRAINT [FK_ExRateSchedule_User] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser])
);

