CREATE TABLE [dbo].[AdditionalField] (
    [IdAdditionalField] INT           IDENTITY (1, 1) NOT NULL,
    [FieldName]         VARCHAR (200) NULL,
    [FieldLabel]        VARCHAR (200) NOT NULL,
    [IdDataType]        INT           NOT NULL,
    [DefaultValue]      VARCHAR (100) NULL,
    [PlaceHolder]       VARCHAR (200) NULL,
    [Order]             INT           NOT NULL,
    [Required]          BIT           NOT NULL,
    [FieldMax]          INT           NULL,
    [FieldMin]          INT           NULL,
    [ValidationRegEx]   VARCHAR (200) NULL,
    [ErrorMessage]      VARCHAR (200) NULL,
    [CatalogResource]   VARCHAR (100) NULL,
    [DependsOn]         INT           NULL,
    PRIMARY KEY CLUSTERED ([IdAdditionalField] ASC),
    FOREIGN KEY ([DependsOn]) REFERENCES [dbo].[AdditionalField] ([IdAdditionalField]),
    FOREIGN KEY ([IdDataType]) REFERENCES [dbo].[AdditionalFieldType] ([IdAdditionalFieldType]),
    UNIQUE NONCLUSTERED ([FieldName] ASC)
);

