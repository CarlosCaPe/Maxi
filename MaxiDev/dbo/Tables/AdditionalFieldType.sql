CREATE TABLE [dbo].[AdditionalFieldType] (
    [IdAdditionalFieldType] INT          IDENTITY (1, 1) NOT NULL,
    [FieldType]             VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([IdAdditionalFieldType] ASC),
    UNIQUE NONCLUSTERED ([FieldType] ASC)
);

