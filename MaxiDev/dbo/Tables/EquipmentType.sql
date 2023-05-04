CREATE TABLE [dbo].[EquipmentType] (
    [IdEquipmentType] INT            NOT NULL,
    [Name]            NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_EquipmentType] PRIMARY KEY CLUSTERED ([IdEquipmentType] ASC) WITH (FILLFACTOR = 90)
);

