CREATE TABLE [dbo].[Gateway] (
    [IdGateway]               INT            NOT NULL,
    [GatewayName]             NVARCHAR (MAX) NOT NULL,
    [DateOfLastChange]        DATETIME       NOT NULL,
    [EnterByIdUser]           INT            NOT NULL,
    [Code]                    VARCHAR (20)   NOT NULL,
    [ConnectionType]          VARCHAR (30)   NOT NULL,
    [NextScheduleTime]        DATETIME       NOT NULL,
    [Status]                  INT            NOT NULL,
    [TimeBeforeUnclaimedHold] INT            DEFAULT ((0)) NOT NULL,
    [ImmediateResponse]       BIT            DEFAULT ((0)) NULL,
    [Hide]                    INT            NULL,
    CONSTRAINT [PK_Gateway] PRIMARY KEY CLUSTERED ([IdGateway] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Gateway_GenericStatus] FOREIGN KEY ([Status]) REFERENCES [dbo].[GenericStatus] ([IdGenericStatus]),
    CONSTRAINT [UQ_Gateway_Code] UNIQUE NONCLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90)
);

