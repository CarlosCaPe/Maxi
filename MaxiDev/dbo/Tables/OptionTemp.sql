CREATE TABLE [dbo].[OptionTemp] (
    [IdOption]        INT             NOT NULL,
    [IdModule]        INT             NOT NULL,
    [Name]            VARCHAR (50)    NOT NULL,
    [Description]     VARCHAR (100)   NOT NULL,
    [ParentName]      NVARCHAR (100)  NULL,
    [GroupName]       NVARCHAR (100)  NULL,
    [OrderNumber]     INT             NULL,
    [ShowInMenu]      BIT             DEFAULT ((0)) NOT NULL,
    [ApplicationView] NVARCHAR (1000) NULL,
    [ShorcutImage]    NVARCHAR (2000) NULL,
    [ParentOrder]     INT             NULL,
    [DescriptionES]   NVARCHAR (MAX)  NULL,
    [ParentNameES]    NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_OptionTemp] PRIMARY KEY CLUSTERED ([IdOption] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OptionTemp_Modulo] FOREIGN KEY ([IdModule]) REFERENCES [dbo].[Modulo] ([IdModule])
);

