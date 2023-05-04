CREATE TABLE [dbo].[RelationCountyCountyClass] (
    [IdRelationCountyCountyClass] INT IDENTITY (1, 1) NOT NULL,
    [IdCounty]                    INT NOT NULL,
    [IdCountyClass]               INT NOT NULL,
    CONSTRAINT [PK_RelationCountyCountyClass] PRIMARY KEY CLUSTERED ([IdRelationCountyCountyClass] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RelationCountyCountyClass_County] FOREIGN KEY ([IdCounty]) REFERENCES [dbo].[County] ([IdCounty]),
    CONSTRAINT [FK_RelationCountyCountyClass_CountyClass] FOREIGN KEY ([IdCountyClass]) REFERENCES [dbo].[CountyClass] ([IdCountyClass])
);

