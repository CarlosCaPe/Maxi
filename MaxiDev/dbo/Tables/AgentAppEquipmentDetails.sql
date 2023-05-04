CREATE TABLE [dbo].[AgentAppEquipmentDetails] (
    [IdAgentAppEquipmentDetail] INT            IDENTITY (1, 1) NOT NULL,
    [IdAgentApplication]        INT            NOT NULL,
    [InventoryNumber]           NVARCHAR (MAX) NOT NULL,
    [IdEquipmentType]           INT            NOT NULL,
    [EnterByIdUser]             INT            NOT NULL,
    [DateOfLastChange]          DATETIME       NOT NULL,
    [Brand]                     NVARCHAR (MAX) NULL,
    [Model]                     NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AgentAppEquipment] PRIMARY KEY CLUSTERED ([IdAgentAppEquipmentDetail] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_AgentAppEquipment_Application] FOREIGN KEY ([IdAgentApplication]) REFERENCES [dbo].[AgentApplications] ([IdAgentApplication]),
    CONSTRAINT [FK_AgentAppEquipment_Users] FOREIGN KEY ([EnterByIdUser]) REFERENCES [dbo].[Users] ([IdUser]),
    CONSTRAINT [FK_AgentAppEquipmentDetails_EquipmentType] FOREIGN KEY ([IdEquipmentType]) REFERENCES [dbo].[EquipmentType] ([IdEquipmentType]) NOT FOR REPLICATION
);

