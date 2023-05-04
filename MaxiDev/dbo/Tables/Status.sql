CREATE TABLE [dbo].[Status] (
    [IdStatus]                   INT            NOT NULL,
    [StatusName]                 NVARCHAR (MAX) NOT NULL,
    [PriorityVerification]       INT            NOT NULL,
    [InternalVerification]       BIT            NOT NULL,
    [OldStatusName]              NVARCHAR (MAX) NULL,
    [IsAnActionStatus]           BIT            NOT NULL,
    [SpecialChangeStatus]        BIT            NOT NULL,
    [RetainOperationStatus]      BIT            NOT NULL,
    [RetainOperationStatusClabe] BIT            NOT NULL,
    [CanChangeToAgingHold]       BIT            NULL,
    [IdType]                     INT            NULL,
    [CanChangeRequest]           BIT            NULL,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([IdStatus] ASC) WITH (FILLFACTOR = 90)
);

