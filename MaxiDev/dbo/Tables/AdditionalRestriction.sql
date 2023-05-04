CREATE TABLE [dbo].[AdditionalRestriction] (
    [AdditionalRestrictionId] INT            IDENTITY (1, 1) NOT NULL,
    [ActionCode]              NVARCHAR (4)   NOT NULL,
    [OptionName]              NVARCHAR (MAX) NOT NULL,
    [ModuleName]              NVARCHAR (MAX) NOT NULL,
    [ApplyToMonoAgent]        BIT            NOT NULL,
    PRIMARY KEY CLUSTERED ([AdditionalRestrictionId] ASC)
);

