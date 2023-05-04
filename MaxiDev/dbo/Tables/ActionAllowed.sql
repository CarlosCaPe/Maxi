CREATE TABLE [dbo].[ActionAllowed] (
    [IdAction]        INT            NOT NULL,
    [IdOption]        INT            NOT NULL,
    [Code]            VARCHAR (50)   NOT NULL,
    [Description]     VARCHAR (100)  NOT NULL,
    [OrderNumber]     INT            NULL,
    [IsDefaultOption] BIT            DEFAULT ((0)) NOT NULL,
    [DescriptionES]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ActionAllowed] PRIMARY KEY CLUSTERED ([IdAction] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ActionAllowed_Option] FOREIGN KEY ([IdOption]) REFERENCES [dbo].[Option] ([IdOption])
);

